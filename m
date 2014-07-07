From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next v2 0/4] be2net: patch set
Date: Mon, 7 Jul 2014 09:38:33 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C56C9DF62@CMEXMB1.ad.emulex.com>
References: <1404113493-14851-1-git-send-email-sathya.perla@emulex.com>
 <20140702.184146.931095313472029442.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:5079 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbaGGJie convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 05:38:34 -0400
In-Reply-To: <20140702.184146.931095313472029442.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> 
> From: Sathya Perla <sathya.perla@emulex.com>
> Date: Mon, 30 Jun 2014 13:01:29 +0530
> 
> > v2 change: merged 2 lines into one in patch 4
> >
> > Patch 1 refactors be_cmd_get_profile_config() routine to reduce
> > code duplication by using the be_cmd_notify_wait() routine, instead
> > of using a separate variant of the code for MBOX and MCCQ.
> >
> > Patch 2 introduces the required FW-cmd code in the PF to query
> > RSS support on a VF. This is in preparation for patch 3.
> >
> > Patch 3 adds support for the PF driver to re-configure the resource
> > distribution in FW based on the number of VFs enabled by the user. When
> > the user is not interested in enabling VFs, all resources of a port are
> > set-aside for the PF. If less than maximum number of VFs are enabled,
> then
> > each VF gets a better share of the resources and can now enable RSS (if
> > the interface supports it.)
> >
> > Patch 4 is a minor fix to re-enable HW vlan filtering as soon as the number
> > of vlans programmed is within the HW limit.
> >
> > Please consider applying to net-next tree. Thanks!
> 
> Series applied, thanks.

David, this patch-set doesn't seem to show up on the net-next tree.
Could you pls check.

thanks,
-Sathya
