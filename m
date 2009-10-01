From: David Dillow <dave@thedillows.org>
Subject: Re: r8169c: Support for Realtek 8168DP chip?
Date: Thu, 01 Oct 2009 11:49:30 -0400
Message-ID: <1254412170.12500.8.camel@lap75545.ornl.gov>
References: <4AC494EC.8050405@ts.fujitsu.com>
 <1254404310.24972.4.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rainer Koenig <Rainer.Koenig@ts.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute1.ornl.gov ([160.91.4.119]:42441 "EHLO emroute1.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbZJAPt3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 11:49:29 -0400
Received: from emroute1.ornl.gov ([127.0.0.1])
 by emroute1.ornl.gov (PMDF V6.4 #31561)
 with ESMTP id <0KQU002GVEMKLJ@emroute1.ornl.gov> for netdev@vger.kernel.org;
 Thu, 01 Oct 2009 11:49:32 -0400 (EDT)
In-reply-to: <1254404310.24972.4.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-01 at 09:38 -0400, David Dillow wrote:
> On Thu, 2009-10-01 at 13:39 +0200, Rainer Koenig wrote:
> > The reason why is easy to decode when looking at the source: The
> > TxConfig register returns 2b800000 and there is no MAC_VERSION in the
> > list of valid versions. That means not PHY initialization code is
> > executed and stop, no working device. :-(
> 
> Francois Romieu posted a patch yesterday (today, his time) to the thread
> "r8169 chips on some Intel D945GSEJT boards fail to work after PXE boot"
> 
> It looks to add MAC support for your card; you should be able to find it
> at any of your favorite mail archives, Google, or better yet,
> http://patchwork.ozlabs.org/project/netdev/list/
> 
> Hmm, patchwork doesn't seem to have picked it up, yet.

Actually, it is there, you just need to change the filters to show
patches in state "RFC".
