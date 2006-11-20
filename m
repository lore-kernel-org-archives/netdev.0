From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/4] atl1: Main C file for Attansic L1 driver
Date: Mon, 20 Nov 2006 15:17:02 -0800
Message-ID: <20061120151702.054bc541@dxpl.pdx.osdl.net>
References: <20061119203050.GD29736@osprey.hogchain.net>
	<200611200057.45274.arnd@arndb.de>
	<45614769.4020005@redhat.com>
	<200611201322.00495.arnd@arndb.de>
	<20061120100202.6a79e382@freekitty>
	<4562036E.3020409@garzik.org>
	<20061120121524.68cf39d8@freekitty>
	<45621FEB.204@garzik.org>
	<20061120135959.66debead@freekitty>
	<45622654.7030400@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Chris Snook <csnook@redhat.com>,
	Jay Cliburn <jacliburn@bellsouth.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:16018 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S966521AbWKTXSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 18:18:36 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45622654.7030400@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Nov 2006 17:04:04 -0500
Jeff Garzik <jeff@garzik.org> wrote:

> Stephen Hemminger wrote:
> > What I would like is for the mii core to maintain the bits (like advertising)
> > in the mii structure and if not running, it should just change the offline
> > copy, then when link is brought up use the changes that were requested while
> > link was down. Understand?
> > 
> > That's why in the skge/sky2, I keep state bits and don't apply them until
> > link is started. If mii (and phylib) did this, I could use them; but as it
> > is they require PHY to be powered all the time.
> 
> 
> You have the power to change it :)  But need to review the other drivers 
> to assess the impact of the change, of course.

planned to, in due course.
