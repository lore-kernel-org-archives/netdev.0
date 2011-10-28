From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Sat, 29 Oct 2011 00:35:24 +0300
Message-ID: <CAEnQRZCxSPb8NRceB+tfdZnkN=K-jGbdmXDgNwEhZFYAWGmvAg@mail.gmail.com>
References: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
	<1319836443-4419-1-git-send-email-dbaluta@ixiacom.com>
	<20111028.171904.1635229691857703124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	luto@amacapital.net, rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:38740 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755579Ab1J1VfZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 17:35:25 -0400
Received: by qyk4 with SMTP id 4so2615439qyk.19
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2011 14:35:25 -0700 (PDT)
In-Reply-To: <20111028.171904.1635229691857703124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 29, 2011 at 12:19 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Daniel Baluta <dbaluta@ixiacom.com>
> Date: Sat, 29 Oct 2011 00:14:03 +0300
>
>> +static inline int tcp_delack_thresh(const struct sock *sk)
>> +{
>> + =A0 =A0 return inet_csk(sk)->icsk_ack.rcv_mss * sysctl_tcp_delack_=
segs;
>> +}
>> +
>
> Please turn this into a shift or something, you're adding a multiply
> into a core code path.

Is there any generic API to do this? Default case is not
affected since tcp_delack_segs is 1.

Daniel.
