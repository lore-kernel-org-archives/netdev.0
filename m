From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH, RFT] bcm43xx: init routine rewrite (bugfix)
Date: Thu, 6 Jul 2006 15:35:00 -0400
Message-ID: <20060706193455.GB6259@tuxdriver.com>
References: <200607012214.24335.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:16910 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750752AbWGFTfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 15:35:25 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200607012214.24335.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 01, 2006 at 10:14:23PM +0200, Michael Buesch wrote:
> Hi,
> 
> This patch is a rewrite of the bcm43xx init routine.
> It is supposed to fix several issues:
> * up-down-up.. sequence stale-data issue
>   (This may fix dhclient issues)
> * Fix init vs IRQ race.
> * Fix init for cards with multiple cores (APHY)
>   (untested)
> * Fix controller restart breakage.
> * Make used wireless core (phymode) selectable at runtime.
> * Well, few others. Don't remember :)

Since your subject includes "RFT", I'm NOT going to apply this.
Please correct me if your desire is otherwise.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
