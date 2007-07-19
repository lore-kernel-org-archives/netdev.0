From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [4/8]
Date: Thu, 19 Jul 2007 09:39:47 +0100
Message-ID: <20070719083947.GB2936@infradead.org>
References: <469EEE4B.2090008@realitydiluted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44610 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756817AbXGSIjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 04:39:48 -0400
Content-Disposition: inline
In-Reply-To: <469EEE4B.2090008@realitydiluted.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 18, 2007 at 11:53:31PM -0500, Steven J. Hill wrote:
> Add main 642xx support to 'drivers/net/mv643xx_eth.c' file.

This is a little too much ifdef mess.  Please factor per-controller type
code into helper functions, and if they're too much have separate files
for either type.
