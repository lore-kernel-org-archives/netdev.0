From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: pskb_copy() in tcp_transmit_skb()
Date: Tue, 13 Sep 2011 12:21:37 +0300
Message-ID: <201109131221.37561.christoph.paasch@uclouvain.be>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:58589 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab1IMJVm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 05:21:42 -0400
Received: from cpaasch-mac.localnet (unknown [192.100.124.156])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: cpaasch@smtp6.sgsi.ucl.ac.be)
	by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPSA id 70C871C581C
	for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 11:21:38 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to understand the reason for the possible call to pskb_copy(=
) in=20
tcp_transmit_skb().
I don't find, where we may have a cloned skb entering tcp_transmit_skb(=
).

The original pskb_copy() came from tcp_retransmit_skb() (commit=20
dfb4b9dceb35c567a595ae5e9d035cfda044a103).
But from that point, the git-history does not show where the pskb_copy(=
) is=20
coming from.


Does somebody has an idea, how a cloned skb can be passed to=20
tcp_transmit_skb() and thus trigger this call to pskb_copy().


Thanks for your help,
Christoph


--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
