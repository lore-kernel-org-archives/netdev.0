From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 5/6] igb: Enable SCTP checksum offloading
Date: Tue, 28 Apr 2009 01:54:56 -0700 (PDT)
Message-ID: <20090428.015456.40210071.davem@davemloft.net>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
	<20090428083613.32417.12646.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, vladislav.yasevich@hp.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37619
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753471AbZD1IzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:55:02 -0400
In-Reply-To: <20090428083613.32417.12646.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 28 Apr 2009 01:36:13 -0700

> Originally from: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> This patch, both the driver portion and the sctp code was
> modified by Jesse Brandeburg and is
> 
> Copyright(c) 2009 Intel Corporation.
> 
> Thanks go to Vlad for starting this work.
> 
> Intel 82576 chipset supports SCTP checksum offloading.  This
> patch enables this functionality in the driver.  A new NETIF
> feature is introduced for SCTP checksum offload.  If the driver
> supports CRC32c checksum, it can set this feature flag.  The
> hardware can offload both transmit and receive.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
