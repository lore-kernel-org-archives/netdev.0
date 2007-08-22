From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: export sysctl_xfrm_acq_expires
Date: Wed, 22 Aug 2007 12:44:32 -0700 (PDT)
Message-ID: <20070822.124432.124083784.davem@davemloft.net>
References: <20070822194202.GB17694@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756798AbXHVTod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 15:44:33 -0400
In-Reply-To: <20070822194202.GB17694@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 22 Aug 2007 15:42:02 -0400

> Hey all-
> 	I had noticed that an extra sysctl for xfrm had been added while back
> (specifically sysctl_xfrm_acq_expires).  Unlike its related sysctl's however,
> this was never exported so that out-of-tree modules could access it, and I
> thought it would be a good idea if it was.  This patch handles that.
> 
> Thanks & Regards
> Neil
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

There is no reason for out-of-tree code to access it and no
current examples exist.

It is an internal knob controlling how a specific part of the IPSEC
rule lookup operates, and that is all in-tree.

