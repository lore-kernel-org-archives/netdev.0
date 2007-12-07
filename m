From: Ben Dooks <ben@fluff.org>
Subject: Re: [patch 06/22] NET: DM9000: Use kthread to probe MII status
	when device open
Date: Fri, 7 Dec 2007 18:33:07 +0000
Message-ID: <20071207183307.GI3244@fluff.org.uk>
References: <20071119203910.687238131@fluff.org> <20071119204013.745821010@fluff.org> <474780AB.20801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	vince@simtec.co.uk
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:60184 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756860AbXLGSdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 13:33:14 -0500
Content-Disposition: inline
In-Reply-To: <474780AB.20801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 23, 2007 at 08:38:51PM -0500, Jeff Garzik wrote:
> seems like a delayed workqueue would be most appropriate for this.

I like the fact that the use of kthread shows the user how much
cpu time is being used by the execution of monitoring the phy. How
badly do people object to using a kthread?

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
