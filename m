From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add new QCA alx ethernet driver
Date: Tue, 14 Aug 2012 22:32:58 -0700 (PDT)
Message-ID: <20120814.223258.1180104882398843954.davem@davemloft.net>
References: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
	<20120811135044.529a7081@nehalam.linuxnetplumber.net>
	<6349D7A510622448B1BA0967850A84380136A1EF@NASANEXD02D.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, xiong@qca.qualcomm.com,
	hao-ran.liu@canonical.com, joe@perches.com,
	rodrigue@qca.qualcomm.com
To: cjren@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab2HOFdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 01:33:01 -0400
In-Reply-To: <6349D7A510622448B1BA0967850A84380136A1EF@NASANEXD02D.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Date: Wed, 15 Aug 2012 03:29:26 +0000

>>> +	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
>>> ...
>>> +	strcpy(netdev->name, "eth%d");
>>> +	retval = register_netdev(netdev);
>>
>>The strcpy is unnecessary, alloc_etherdev already sets that.
> 
> The strcpy is useful. netdev->name is set as pci_name in front. So the strcpy restores it.

Are you doing this just to influence the initial driver log messages?

Don't do that, it's gross.
