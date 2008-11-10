From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [irda-users] [1/3] IRDA: Create new field tx_extra in skbuff
Date: Mon, 10 Nov 2008 17:47:32 +0100
Message-ID: <20081110164732.GA7511@sortiz.org>
References: <49185CBD.2040601@ceibo.fiec.espol.edu.ec>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org
To: Alex =?iso-8859-1?B?VmlsbGFj7a1z?= Lasso
	<avillaci@ceibo.fiec.espol.edu.ec>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.101]:48709 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481AbYKJQot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 11:44:49 -0500
Content-Disposition: inline
In-Reply-To: <49185CBD.2040601@ceibo.fiec.espol.edu.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On Mon, Nov 10, 2008 at 11:09:33AM -0500, Alex Villac=ED=ADs Lasso wrot=
e:
> This patch and the other two that follow fix the issue for me under =20
> 2.6.28-rc3. Please comment on this, as I am messing around with the =20
> skbuff structure, which potentially affects all network stacks.
Adding 32 bytes to _all_ skbs is a no-no.
This is an IrDA specific issue, and it has to be fixed in an IrDA speci=
fic
way. My patches work with my irda-usb and mcs7780 dongles. If they dont=
 for
you, then we should dump the kernel stack when we're hitting the proble=
m of
not having reserved enough headroom for the irda cb.
Evgeniy's proposal could also be another solution.


Cheers,
Samuel.

