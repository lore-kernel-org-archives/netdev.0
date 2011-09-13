From: Gaofeng <gaofeng@cn.fujitsu.com>
Subject: Re: pskb_copy() in tcp_transmit_skb()
Date: Tue, 13 Sep 2011 17:29:25 +0800
Message-ID: <4E6F2275.2050902@cn.fujitsu.com>
References: <201109131221.37561.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56457 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750777Ab1IMJ3E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 05:29:04 -0400
In-Reply-To: <201109131221.37561.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  =E4=BA=8E 2011=E5=B9=B409=E6=9C=8813=E6=97=A5 17:21, Christoph Paasch=
 =E5=86=99=E9=81=93:
> Hi,
>
> I'm trying to understand the reason for the possible call to pskb_cop=
y() in
> tcp_transmit_skb().
> I don't find, where we may have a cloned skb entering tcp_transmit_sk=
b().
>
> The original pskb_copy() came from tcp_retransmit_skb() (commit
> dfb4b9dceb35c567a595ae5e9d035cfda044a103).
> But from that point, the git-history does not show where the pskb_cop=
y() is
> coming from.
>
>
> Does somebody has an idea, how a cloned skb can be passed to
> tcp_transmit_skb() and thus trigger this call to pskb_copy().
>
>
> Thanks for your help,
> Christoph
>
>
> --
> Christoph Paasch
> PhD Student
>
> IP Networking Lab --- http://inl.info.ucl.ac.be
> MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
> Universit=C3=A9 Catholique de Louvain
>
> www.rollerbulls.be
> --
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
maybe nat,nat can change the tcp packet header
