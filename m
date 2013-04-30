From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipv6: add support of peer address
Date: Tue, 30 Apr 2013 10:31:40 +0200
Message-ID: <517F816C.8080405@6wind.com>
References: <1367268252-4810-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:35380 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759465Ab3D3Ibn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 04:31:43 -0400
Received: by mail-wg0-f47.google.com with SMTP id j13so205529wgh.26
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 01:31:42 -0700 (PDT)
In-Reply-To: <1367268252-4810-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/04/2013 22:44, Nicolas Dichtel a =C3=A9crit :
> This patch adds the support of peer address for IPv6. For example, it=
 is
> possible to specify the remote end of a 6inY tunnel.
> This was already possible in IPv4:
>   ip addr add ip1 peer ip2 dev dev1
>
> The peer address is specified with IFA_ADDRESS and the local address =
with
> IFA_LOCAL (like explained in include/uapi/linux/if_addr.h).
> Note that the API is not changed, because before this patch, it was n=
ot
> possible to specify two different addresses in IFA_LOCAL and IFA_REMO=
TE.
> There is a small change for the dump: if the peer is different from :=
:,
> IFA_ADDRESS will contain the peer address instead of the local addres=
s.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Please, drop this patch. I must rework it.
