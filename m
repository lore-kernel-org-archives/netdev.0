From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: [PATCH net-next 0/6] net/core, bonding: dev_uc_sync fixes,
 bonding update
Date: Fri, 31 May 2013 10:28:12 -0500
Message-ID: <20130531152812.GB2910@sbohrermbp13-local.rgmadvisors.com>
References: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
 <20130531.013155.25881045915195152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, vyasevic@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f41.google.com ([209.85.212.41]:42230 "EHLO
	mail-vb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756289Ab3EaP2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 11:28:16 -0400
Received: by mail-vb0-f41.google.com with SMTP id p14so1148439vbm.28
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 08:28:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130531.013155.25881045915195152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 31, 2013 at 01:31:55AM -0700, David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Thu, 30 May 2013 17:55:38 -0700
> 
> > 	This patch set includes 6 patches: four fixes to the dev_mc_sync /
> > dev_mc_unsync system; and two patches to bonding, one to utilize the sync
> > / unsync functions, and another minor fix related to MAC address handling.
> 
> These look like fixes that should go into net, why target net-next?

In my oppinion 0-4 should go into net since they fix the bug I
reported in:

http://comments.gmane.org/gmane.linux.network/270477

I've tested patches 0-4 of this series so feel free to add my tested
by to those:

Tested-by: Shawn Bohrer <sbohrer@rgmadvisors.com>

>From just a casual observation of patch 5-6 they do not appear to be
bug fixes which is why this was probably marked net-next.

--
Shawn
