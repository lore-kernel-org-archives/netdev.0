From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/4] qlcnic: Bug fixes
Date: Tue, 25 Feb 2014 18:33:45 -0500 (EST)
Message-ID: <20140225.183345.572824679862939338.davem@davemloft.net>
References: <1393250089-31104-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaBYXdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 18:33:47 -0500
In-Reply-To: <1393250089-31104-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Mon, 24 Feb 2014 08:54:45 -0500

> This patch series includes following bug fixes,
> 
> * Fix for return value handling of function qlcnic_enable_msi_legacy().
> * Fix for the usage of module parameters for interrupt mode.
>   Driver should use flags while checking for driver's interrupt mode instead of
>   module parameters.
> * Revert commit 1414abea04 (qlcnic: Restrict VF from configuring any VLAN mode),
>   in order to save some multicast filters.
> * Fix a bug where driver was not re-setting sds ring count to 1 when
>   it falls back from MSI-x mode to legacy interrupt mode.
> 
> Please apply to net.
> 
> Change in v2 -
> Dropped patch "qlcnic: reset firmware API lock during driver load" for further rework.

Series applied, thanks Shahed.
