From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 4/4] geneve: Add geneve_get_rx_port support
Date: Fri, 11 Dec 2015 20:00:25 -0500 (EST)
Message-ID: <20151211.200025.1303522501610446543.davem@davemloft.net>
References: <1449598334-97674-1-git-send-email-anjali.singhai@intel.com>
	<1449598334-97674-5-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.org
To: anjali.singhai@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbbLLBA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 20:00:27 -0500
In-Reply-To: <1449598334-97674-5-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>
Date: Tue,  8 Dec 2015 10:12:14 -0800

> This patch adds an op that the drivers can call into to get existing
> geneve ports.
> 
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>

Add the new geneve infrastructure in one patch, then add the
call from the driver in another.

This looks like just a geneve change from the Subject line,
but what's hidden is that i40e is changed too.
