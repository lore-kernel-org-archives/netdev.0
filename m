From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: Fix - Do not allow Rx FC on 82598
 at 1G due to errata
Date: Mon, 15 Feb 2010 21:52:09 -0800 (PST)
Message-ID: <20100215.215209.110534825.davem@davemloft.net>
References: <20100211141319.25672.3041.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750759Ab0BPFv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:51:56 -0500
In-Reply-To: <20100211141319.25672.3041.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 11 Feb 2010 06:13:49 -0800

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> The 82598 has an erratum that receipt of pause frames at 1G
> could lead to a Tx Hang.  To avoid this this patch disables
> Rx FC while at 1G speed for all 82598 parts.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
