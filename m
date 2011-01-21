From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Bug Fix: Dont reset
 ENIC_SET_APPLIED flag on port profile disassociate
Date: Thu, 20 Jan 2011 16:57:02 -0800 (PST)
Message-ID: <20110120.165702.228968214.davem@davemloft.net>
References: <20110121003554.25697.15096.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55306
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755159Ab1AUA41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 19:56:27 -0500
In-Reply-To: <20110121003554.25697.15096.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Thu, 20 Jan 2011 16:35:54 -0800

> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> enic_get_vf_port returns port profile operation status only if ENIC_SET_APPLIED
> flag is set. A recent rework of enic_set_port_profile added code to reset this
> flag on disassociate. As a result of which a client calling enic_get_vf_port
> to get the status of port profile disassociate will always get a return value
> of ENODATA. This patch renames ENIC_SET_APPLIED to more appropriate
> ENIC_PORT_REQUEST_APPLIED and reverts back the recent change so that the
> flag is set both at associate and disassociate of a port profile.
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>

Applied.
