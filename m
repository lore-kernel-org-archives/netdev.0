From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [PATCH] ibm_emac: Correctly detect old link speed
Date: Wed, 16 May 2007 10:30:02 -0700
Message-ID: <20070516173002.GA22331@gate.ebshome.net>
References: <200705161300.08521.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:50687 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756877AbXEPRgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 13:36:43 -0400
Content-Disposition: inline
In-Reply-To: <200705161300.08521.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2007 at 01:00:08PM +0200, Stefan Roese wrote:
> This patch fixes a bug where the link speed change was not
> detected correctly. This occured on a 440SPe (EMAC4) system
> where the old link speed was 100Mbps and the new link speed
> is 1000Mbps.

Good catch, Stefan. Unfortunately, I have to NACK your patch - you 
broke non EMAC4 builds.

Correct fix is just to remove EMAC_MR1_MF_1000GPCS from the first 
if condition.

I'll send correct fix shortly along with other queued patches.

-- 
Eugene

