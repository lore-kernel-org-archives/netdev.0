From: Stefan Schmidt <stefan@datenfreihafen.org>
Subject: Re: forcedeth: Reside in 100Mbit Kconfig but also supports 1000Mbit cards
Date: Sun, 27 May 2007 02:56:09 +0200
Message-ID: <20070527005609.GB9566@datenfreihafen.org>
References: <20070526230750.GA9566@datenfreihafen.org> <20070526172929.755b8d98.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aabdulla@nvidia.com, netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([62.75.240.18]:48119 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbXE0A4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2007 20:56:21 -0400
Content-Disposition: inline
In-Reply-To: <20070526172929.755b8d98.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On Sat, 2007-05-26 at 17:29, Randy Dunlap wrote:
> On Sun, 27 May 2007 01:07:50 +0200 Stefan Schmidt wrote:
> 
> > 
> > What would be the best way to deal with this if there are some
> > 10/100Mbit cards which use the same driver as 1000Mbit cards?
> 
> There has been some mention of dropping the 10/100 and 1000
> categories and just merging all of them together.
> Makes sense to me.

I still like the partition by speed. It makes it a lot easier to find
the right driver in the bunch of available ones. A solution like a
Kconfig entry symlink for driver which needs to support cards in two
or more categories would be my favorite.

regards
Stefan Schmidt
