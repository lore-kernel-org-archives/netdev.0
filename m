From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next v3 2/2] be2net: csum, tso and rss steering
 offload support for VxLAN
Date: Thu, 27 Mar 2014 05:07:41 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C2A41B74C@CMEXMB1.ad.emulex.com>
References: <1395755430-17451-1-git-send-email-sathya.perla@emulex.com>
	<1395755430-17451-3-git-send-email-sathya.perla@emulex.com>
 <20140326.152925.636540498299329092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:27628 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaC0FHn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 01:07:43 -0400
In-Reply-To: <20140326.152925.636540498299329092.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> 
> From: Sathya Perla <sathya.perla@emulex.com>
> Date: Tue, 25 Mar 2014 19:20:30 +0530
> 
> > This patch mainly implements the add/del_vxlan_port() methods by invoking
> > the needed FW cmds for supporting VxLAN offloads for Skyhawk-R.
> >
> > Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> 
> I know Or Gerlitz mentioned sleeping and that's where this workqueue comes
> from, but please I'd say to not add this if it's not necessary.
> 
> be_cmd_set_profile_config() runs with a BH spinlock held during it's
> entirety, it will never sleep.
> 
> So please go back to what you were doing in the first revision of this
> patch and submit the command synchronously rather than via a workqueue.

:-) Ok, I'll send out a v4 patch-set. Thanks. 
