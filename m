From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] sb1250-mac: Driver model & phylib update
Date: Tue, 25 Sep 2007 14:18:17 +0100
Message-ID: <20070925131817.GA28402@linux-mips.org>
References: <Pine.LNX.4.64N.0709191811040.24627@blysk.ds.pg.gda.pl> <20070921124409.7f3d122b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:44620 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbXIYNSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 09:18:47 -0400
Content-Disposition: inline
In-Reply-To: <20070921124409.7f3d122b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 21, 2007 at 12:44:09PM -0700, Andrew Morton wrote:

> >  A driver model and phylib update.
> 
> akpm:/usr/src/25> diffstat patches/git-net.patch | tail -n 1
>  1013 files changed, 187667 insertions(+), 23587 deletions(-)
> 
> Sorry, but raising networking patches against Linus's crufty
> old mainline tree just isn't viable at present.

Out of curiosity:

[ralf@denk linux-queue]$ git diff $(git merge-base master v2.6.23-rc8-mm1)..v2.6.23-rc8-mm1 | wc -cl
1046669 31900996
[ralf@denk linux-queue]$ git diff $(git merge-base master v2.6.23-rc8-mm1)..v2.6.23-rc8-mm1 | diffstat | tail -1
 6049 files changed, 573635 insertions(+), 207630 deletions(-)
[ralf@denk linux-queue]$ 

We're all a little too productive ;-)

  Ralf
