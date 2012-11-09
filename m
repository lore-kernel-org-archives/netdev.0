From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Fri, 09 Nov 2012 10:50:34 +0800
Message-ID: <509C6F7A.30308@gmail.com>
References: <1335522818.2775.227.camel@edumazet-glaptop>  <509A19E6.4040707@gmail.com>  <509A1D49.4080306@gmail.com>  <1352286264.3140.3575.camel@edumazet-glaptop> <509B6368.9010206@gmail.com>  <1352381449.19779.13.camel@edumazet-glaptop> <509C6AEF.4020300@gmail.com> <1352428675.19779.490.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54525 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab2KICuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 21:50:52 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so2497119pbb.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 18:50:52 -0800 (PST)
In-Reply-To: <1352428675.19779.490.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B411=E6=9C=8809=E6=97=A5 10:37, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Fri, 2012-11-09 at 10:31 +0800, Li Yu wrote:
>
>> I think that adding skb->frag_head indeed is a better choice, this m=
eans
>> I have to rework some NIC drivers :(
>
> Not sure what you mean, since most (if not all) NIC drivers already u=
se
> skb->frag_head in their RX path.
>

skb =3D build_skb(data, 0); in bnx2 and bnx2x ......

:)

Yu
