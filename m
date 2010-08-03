From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: RFC: New BPF 'LOOP' instruction
Date: Tue, 3 Aug 2010 18:17:40 +0300
Message-ID: <201008031817.40664.remi@remlab.net>
References: <20100803070426.GN11110@cel.leo> <f350f48de92da479bfb224527bc70c10@chewa.net> <20100803141924.GV11110@cel.leo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:56715 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756911Ab0HCPRn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 11:17:43 -0400
Received: from basile.remlab.net (cs27070146.pp.htv.fi [89.27.70.146])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: remi)
	by yop.chewa.net (Postfix) with ESMTPSA id DF8DE76A
	for <netdev@vger.kernel.org>; Tue,  3 Aug 2010 17:17:41 +0200 (CEST)
In-Reply-To: <20100803141924.GV11110@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 3 ao=FBt 2010 17:19:24 Paul LeoNerd Evans, vous avez =E9crit :
> On Tue, Aug 03, 2010 at 04:16:02PM +0200, R=E9mi Denis-Courmont wrote=
:
> > > Is there any way it could be done lazily, at the moment that filt=
er.c
> > > knows it has to provide either SKF_TRANS_OFF or SKF_AD_TRANSPROTO=
?
> >=20
> > You would essentially need to implement dedicated parsing for each
> > protocols family.
> > So you might as well add an opcode dedicated to IPv6...
>=20
> And what happens when IPv8 comes along?
> Or we want to parse IPX/SPX or
> any of those thousands of other network protocols?

It does not work. That's why your SKB_TRANS_OFF proposal sucks totally =
because=20
it is not implementable. On the other hand, n IPv6-specific opcode suck=
s only=20
a little due to its ugliness and lack of forward compatibility.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
