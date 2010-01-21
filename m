From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] e1000e: enhance frame fragment detection
Date: Wed, 20 Jan 2010 16:21:41 -0800 (PST)
Message-ID: <20100120.162141.190060489.davem@davemloft.net>
References: <20100120001511.25175.55030.stgit@localhost.localdomain>
	<20100120001558.25175.87922.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, nhorman@tuxdriver.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754003Ab0AUAVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 19:21:30 -0500
In-Reply-To: <20100120001558.25175.87922.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 19 Jan 2010 16:15:59 -0800

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Originally patched by Neil Horman <nhorman@tuxdriver.com>
> 
> e1000e could with a jumbo frame enabled interface, and packet split disabled,
> receive a packet that would overflow a single rx buffer.  While in practice
> very hard to craft a packet that could abuse this, it is possible.
> 
> this is related to CVE-2009-4538
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
