From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] igmp: remove unnecessary in_device member
 zeroing
Date: Wed, 12 Jun 2013 00:42:01 -0700 (PDT)
Message-ID: <20130612.004201.848052130607117743.davem@davemloft.net>
References: <1370626483-23776-1-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sbohrer@rgmadvisors.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab3FLHmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 03:42:02 -0400
In-Reply-To: <1370626483-23776-1-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Date: Fri,  7 Jun 2013 12:34:43 -0500

> ip_mc_init_dev() is passed a freshly kzalloc'd in_device so it is
> unnecessary to explicitly zero out the members.
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>

Applied, thanks.
