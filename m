From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 02/21] qlcnic: create seperate file for data path
 routines
Date: Wed, 24 Oct 2012 23:10:58 -0400 (EDT)
Message-ID: <20121024.231058.2042587746412597890.davem@davemloft.net>
References: <1351031472-731-1-git-send-email-sony.chacko@qlogic.com>
	<1351031472-731-3-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933068Ab2JYDLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 23:11:00 -0400
In-Reply-To: <1351031472-731-3-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Tue, 23 Oct 2012 18:30:53 -0400

> +static inline bool qlcnic_82xx_check(struct qlcnic_adapter *adapter)
> +{
> +	return (adapter->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE824X) ? 1 : 0;
> +}

"bool" is either "true" or "false", so return "true" or "false" rather
than "1" or "0"
