From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: wireless: mwifiex: initial commit for Marvell mwifiex driver
Date: Thu, 26 Apr 2012 15:51:02 +0300
Message-ID: <20120426125102.GA14808@mwanda>
References: <20120425084445.GA12799@elgon.mountain>
 <477F20668A386D41ADCC57781B1F7043083A3CC5FF@SC-VEXCH1.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bing Zhao <bzhao@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:51142 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab2DZMs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 08:48:28 -0400
Content-Disposition: inline
In-Reply-To: <477F20668A386D41ADCC57781B1F7043083A3CC5FF@SC-VEXCH1.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 25, 2012 at 03:08:33PM -0700, Bing Zhao wrote:
> > ->oui is only a 3 byte array so we're reading past the end for this
> > comparison.
> 
> I will fix the misuse of memcmp's.
> 

So it wasn't really a bug right?  Just a bit confusing.

> By the way, could you please share with me how you check for this kind of errors?
> Is it coccinelle? I tried with coccicheck but got "spatch.opt unknown option -D" error.
> 

This was from a Smatch check that I haven't pushed yet.

regards,
dan carpenter
