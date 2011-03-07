From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH 3/8] Phonet: fix backlog callback return value
Date: Mon, 7 Mar 2011 22:30:13 +0200
Message-ID: <201103072230.14080.remi@remlab.net>
References: <201103031322.37184.remi.denis-courmont@nokia.com> <1299232831-3132-3-git-send-email-remi.denis-courmont@nokia.com> <20110307.122329.39193888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:42904 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203Ab1CGUaR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 15:30:17 -0500
Received: from basile.remlab.net (cs27069010.pp.htv.fi [89.27.69.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: remi)
	by yop.chewa.net (Postfix) with ESMTPSA id 32752139E
	for <netdev@vger.kernel.org>; Mon,  7 Mar 2011 21:30:15 +0100 (CET)
In-Reply-To: <20110307.122329.39193888.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 7 mars 2011 22:23:29 David Miller, vous avez =E9crit :
> More verbose commit message please.
>=20
> What was wrong with the old error values and what exactly do
> you claim to be doing to correct them?

They were returning -Exxx errno's where the caller expected NET_RX_* va=
lues.
I can "fix" it but it seemed obvious.

--=20
R=E9mi Denis-Courmont
http://www.remlab.info/
http://fi.linkedin.com/in/remidenis
