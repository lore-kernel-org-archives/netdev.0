From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PCNET32] Lock solid with netconsole
Date: Wed, 30 May 2007 13:41:50 +0200
Message-ID: <20070530114150.GA17818@electric-eye.fr.zoreil.com>
References: <JIUG4Z$FE429A5F18B9052E8E0CF6906B6CB68A@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tsbogend <tsbogend@alpha.franken.de>,
	lsorense <lsorense@csclub.uwaterloo.ca>,
	pcnet32 <pcnet32@verizon.net>, netdev <netdev@vger.kernel.org>
To: Emmanuel =?iso-8859-1?Q?Fust=E9?= <emmanuel.fuste@laposte.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44106 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897AbXE3LoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 07:44:05 -0400
Content-Disposition: inline
In-Reply-To: <JIUG4Z$FE429A5F18B9052E8E0CF6906B6CB68A@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Emmanuel Fust=E9 <emmanuel.fuste@laposte.net> :
[..]
> Could this bug fix from Stephen Hemminger be another track to follow =
?
> http://marc.info/?l=3Dlinux-netdev&m=3D118048588011069&w=3D2
> If you think so, I could give it a try whitout applying the "spin_loc=
k_irqsave" patch.

You can apply it too but Stephen's patch addresses a different issue an=
d
pcnet32 does not use netif_tx_locking (it could/should though).

--=20
Ueimor
