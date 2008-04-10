From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] sky2: missing chip name for Yukon Supreme
Date: Thu, 10 Apr 2008 16:14:21 -0400
Message-ID: <20080410201421.GA27486@infradead.org>
References: <20080410150614.7da71ff8@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:36192 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757485AbYDJUOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 16:14:30 -0400
Content-Disposition: inline
In-Reply-To: <20080410150614.7da71ff8@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 10, 2008 at 03:06:14PM -0500, Stephen Hemminger wrote:
> Any usage of sky2 on new Yukon Supreme would cause a NULL dereference.
> The chip is very new, so the support is still untested; vendor has
> not sent any eval hardware.

What about also making the driver not oops in case another variant is added?
