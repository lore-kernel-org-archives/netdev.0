From: Bing Zhao <bzhao@marvell.com>
Subject: RE: wireless: mwifiex: initial commit for Marvell mwifiex driver
Date: Thu, 26 Apr 2012 12:25:27 -0700
Message-ID: <477F20668A386D41ADCC57781B1F7043083A3CC842@SC-VEXCH1.marvell.com>
References: <20120425084445.GA12799@elgon.mountain>
 <477F20668A386D41ADCC57781B1F7043083A3CC5FF@SC-VEXCH1.marvell.com>
 <20120426125102.GA14808@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:57764 "EHLO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755088Ab2DZT0w convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 15:26:52 -0400
In-Reply-To: <20120426125102.GA14808@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

> On Wed, Apr 25, 2012 at 03:08:33PM -0700, Bing Zhao wrote:
> > > ->oui is only a 3 byte array so we're reading past the end for this
> > > comparison.
> >
> > I will fix the misuse of memcmp's.
> >
> 
> So it wasn't really a bug right?  Just a bit confusing.

That's right. I will submit a patch to fix the confusion.

> 
> > By the way, could you please share with me how you check for this kind of errors?
> > Is it coccinelle? I tried with coccicheck but got "spatch.opt unknown option -D" error.
> >
> 
> This was from a Smatch check that I haven't pushed yet.

Are you going to push it soon? I'm eager to use it checking my code.

Thanks,
Bing

> 
> regards,
> dan carpenter
