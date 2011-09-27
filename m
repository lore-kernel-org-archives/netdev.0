From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next] tcp: unalias tcp_skb_cb flags and ip_dsfield
Date: Tue, 27 Sep 2011 11:38:00 +0300
Message-ID: <201109271138.00318.christoph.paasch@uclouvain.be>
References: <1317103249.2796.25.camel@edumazet-laptop> <201109271037.38786.christoph.paasch@uclouvain.be> <20110927.040853.516739403765881835.davem@davemloft.net>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hkchu@google.com,
	ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:60807 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab1I0IiI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 04:38:08 -0400
In-Reply-To: <20110927.040853.516739403765881835.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 27 September 2011 wrote David Miller:
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Tue, 27 Sep 2011 10:37:38 +0300
>=20
> > However, (as far as I can see) before Eric's change it was 42 bytes=
 long
> > and now it became 43 bytes.
>=20
> Then, I suggest that you go buy a pair of glasses. :-)

Yeah, maybe it's time to... ;-)

This two-byte hole, is it because "flags" and "sacked" are both __u8 an=
d=20
fields are aligned to 32-bit ?

Thanks,
Christoph

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
