From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] qlcnic: Enhancements and cleanup
Date: Fri, 24 May 2013 23:05:36 -0700 (PDT)
Message-ID: <20130524.230536.1061694307345896229.davem@davemloft.net>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862Ab3EYGFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 02:05:39 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Fri, 24 May 2013 03:04:24 -0400

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> This patch series includes following changes:
> * Support for spoof check configuration per VF using
>   iproute2 tool.
> * Set HW mask for 8300 adapter in INT-x mode to stop generating
>   interrupts.
> * Updated IRQ name for 8200 and 8300 Series adapter as per
>   format used by other multiqueue drivers.
> * Remove qlcnic_config_npars module parameter.
> * Initialize trans_work and idc_aen_work at VF probe.
> * Convert netsted if-else into switch-case statement.
> * Change in diagnostics routine.
> * Modify reset recovery path in diag mode by providing diagnostics
>   routines enough time to unwind before proceeding with reset recovery.
> * Implement GET_LED_STATUS command for 82xx adapter and refactor
>   qlcnic_store_beacon() to split 8200 and 8300 specific calls.
> * Some cleanup and log enhancements
> 
> Please apply to net-next.

Series applied, thanks.
