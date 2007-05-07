From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 7 May 2007 15:46:08 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705071538060.1479@scrub.home>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3y7k1biov.fsf@maximus.localdomain>
 <Pine.LNX.4.64.0705070343330.2733@scrub.home> <m3tzupc6wz.fsf@maximus.localdomain>
 <Pine.LNX.4.64.0705071318150.1479@scrub.home> <m3r6psc0ee.fsf@maximus.localdomain>
 <Pine.LNX.4.64.0705071509290.1479@scrub.home> <463F27CE.2040008@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scrub.xs4all.nl ([194.109.195.176]:1137 "EHLO scrub.xs4all.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933928AbXEGNqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 09:46:12 -0400
In-Reply-To: <463F27CE.2040008@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, 7 May 2007, Jeff Garzik wrote:

> > select seriously screws with the dependencies, it's especially problematic
> > if the selected symbol has other dependencies as HDLC in this case, it makes
> > it only more complicated to get the dependencies correct again.
> > Please use it only if it solves a real problem.
> 
> What he's doing is the standard way to deal with library-style code. Nothing
> wrong with the patch, it's continuing established methods.

select was never meant as autoconfiguration tool. It can't be said often 
enough: select seriously screws with the dependencies, _please_ don't use 
it as a simple depends replacement.
HDLC doesn't really look like simple library code, what's up with all the 
HDLC_* options?

bye, Roman
