From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/7] net: add FCoE offload support through net_device
Date: Thu, 19 Feb 2009 13:24:20 -0800
Message-ID: <20090219132420.4b0dfc09@extreme>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
	<20090219194949.22270.40834.stgit.yi.zou@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
To: Yi Zou <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51471 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755595AbZBSVYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 16:24:22 -0500
In-Reply-To: <20090219194949.22270.40834.stgit.yi.zou@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Feb 2009 12:49:49 -0700
Yi Zou <yi.zou@intel.com> wrote:

> This adds a "struct net_fcoe_ops *fcoe_ops" to net_device struct so any
> network adapter driver can provide Fiber Channle over Ethernet (FCoE) offload
> support through net_device. The fcoe_ops is only available when FCoE is
> enabled in kernel as built-in or module driver.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>

Rather than adding another _ops structure please add to existing
netdevice_ops. You don't need the flags that way. If netdevice_ops
has fcoe_setup, then device can do it...

