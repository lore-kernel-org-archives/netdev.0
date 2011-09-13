From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: pskb_copy() in tcp_transmit_skb()
Date: Tue, 13 Sep 2011 13:55:55 +0300
Message-ID: <201109131355.55588.christoph.paasch@uclouvain.be>
References: <201109131221.37561.christoph.paasch@uclouvain.be> <4E6F2275.2050902@cn.fujitsu.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Gaofeng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:52569 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749Ab1IMK4A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 06:56:00 -0400
In-Reply-To: <4E6F2275.2050902@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tuesday 13 September 2011 wrote Gaofeng:
> > I'm trying to understand the reason for the possible call to pskb_c=
opy()
> > in tcp_transmit_skb().
> > I don't find, where we may have a cloned skb entering tcp_transmit_=
skb().
> >=20
> > The original pskb_copy() came from tcp_retransmit_skb() (commit
> > dfb4b9dceb35c567a595ae5e9d035cfda044a103).
> > But from that point, the git-history does not show where the pskb_c=
opy()
> > is coming from.
> >=20
> >=20
> > Does somebody has an idea, how a cloned skb can be passed to
> > tcp_transmit_skb() and thus trigger this call to pskb_copy().
>
> maybe nat,nat can change the tcp packet header

although NAT may change the TCP header, it is not doing an skb_clone() =
- (at=20
least I don't find it).
Thus, we will not call pskb_copy() in tcp_transmit_skb() due to NAT.

Christoph

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=C3=A9 Catholique de Louvain

www.rollerbulls.be
--
