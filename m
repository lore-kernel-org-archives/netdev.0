From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: thunder: Add ACPI support.
Date: Tue, 11 Aug 2015 11:49:08 -0700 (PDT)
Message-ID: <20150811.114908.1384923604512568161.davem@davemloft.net>
References: <1439254717-2875-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org, rrichter@cavium.com,
	tomasz.nowicki@linaro.org, sgoutham@cavium.com,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	mark.rutland@arm.com, rafael@kernel.org, david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbbHKStJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 14:49:09 -0400
In-Reply-To: <1439254717-2875-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney.cavm@gmail.com>
Date: Mon, 10 Aug 2015 17:58:35 -0700

> Change from v1:  Drop PHY binding part, use fwnode_property* APIs.
> 
> The first patch (1/2) rearranges the existing code a little with no
> functional change to get ready for the second.  The second (2/2) does
> the actual work of adding support to extract the needed information
> from the ACPI tables.

Series applied.

In the future it might be better structured to try and get the OF
node, and if that fails then try and use the ACPI method to obtain
these values.
