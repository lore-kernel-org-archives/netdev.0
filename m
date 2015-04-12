From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: fix bogus RTT for CC when retransmissions
 are acked
Date: Sun, 12 Apr 2015 09:00:28 -0700
Message-ID: <CAK6E8=dmM90jMRRxAEsfW+ErcFaueb2tdRS0BDXAj=aWGYO_TA@mail.gmail.com>
References: <1428711469-5328-1-git-send-email-kennetkl@ifi.uio.no> <CADVnQyk7ZmB6OnCjpZqPy+7_OtUBLT0z_DszowEpu_UpMYpooA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36968 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbbDLQBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 12:01:10 -0400
Received: by igblo3 with SMTP id lo3so28503195igb.0
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 09:01:09 -0700 (PDT)
In-Reply-To: <CADVnQyk7ZmB6OnCjpZqPy+7_OtUBLT0z_DszowEpu_UpMYpooA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 12, 2015 at 7:13 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Fri, Apr 10, 2015 at 8:17 PM, Kenneth Klette Jonassen
> <kennetkl@ifi.uio.no> wrote:
>> Since retransmitted segments are not used for RTT estimation, previously
>> SACKed segments present in the rtx queue are used. This estimation can be
>> several times larger than the actual RTT. When a cumulative ack covers both
>> previously SACKed and retransmitted segments, CC may thus get a bogus RTT.
>>
>> Such segments previously had an RTT estimation in tcp_sacktag_one(), so it
>> seems reasonable to not reuse them in tcp_clean_rtx_queue() at all.
>>
>> Afaik, this has had no effect on SRTT/RTO because of Karn's check.
>>
>> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Tested-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
>
> neal
