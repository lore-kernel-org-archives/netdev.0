From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Subject: RE: [PATCH] net: add new QCA alx ethernet driver
Date: Wed, 15 Aug 2012 03:29:26 +0000
Message-ID: <6349D7A510622448B1BA0967850A84380136A1EF@NASANEXD02D.na.qualcomm.com>
References: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
 <20120811135044.529a7081@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>,
	"Hao-Ran Liu(Joseph Liu)" <hao-ran.liu@canonical.com>,
	Joe Perches <joe@perches.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:31419 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850Ab2HOD32 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 23:29:28 -0400
In-Reply-To: <20120811135044.529a7081@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
>> ...
>> +	strcpy(netdev->name, "eth%d");
>> +	retval = register_netdev(netdev);
>
>The strcpy is unnecessary, alloc_etherdev already sets that.

The strcpy is useful. netdev->name is set as pci_name in front. So the strcpy restores it.

Thanks
cloud
