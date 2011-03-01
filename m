From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Tue, 1 Mar 2011 22:52:52 +0100
Message-ID: <20110301215252.GA13336@electric-eye.fr.zoreil.com>
References: <AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com> <loom.20110206T203347-475@post.gmane.org> <4D4FE100.5090808@gmail.com> <loom.20110214T141934-88@post.gmane.org> <AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com> <loom.20110226T011347-702@post.gmane.org> <AANLkTikSvs7jF9BZzbsYkLAawpCH2h1Z0r09ft219uaa@mail.gmail.com> <loom.20110226T120245-774@post.gmane.org> <AANLkTimmbG3_GjYhoO7F46hOcRM3Fq_mNifk2PpLstPa@mail.gmail.com> <20110301101609.GA13261@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chriss <mail_to_chriss@gmx.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50889 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313Ab1CAV5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 16:57:07 -0500
Content-Disposition: inline
In-Reply-To: <20110301101609.GA13261@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
> Jesse Gross <jesse@nicira.com> :
> [...]
> > Regardless, the solution is to remove the dependency on vlan devices
> > by converting over to the new vlan model.  Francois, any chance that
> > you might have some time to look at this?
> 
> The completely untested patch below is available for the (really) desperate
> souls.
> 
> I should do a -next testing session this afternoon for this patch + 
> Oliver's Neukum advertisement control + Hayes 8105e stuff (in reverse order).

It took a bit longer than expected but the patch seems to work.

Chriss, can you give it a try against current -rc / -git and see if it makes
a difference ?

-- 
Ueimor
