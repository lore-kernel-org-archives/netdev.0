From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Subject: RE: [PATCH] net: add new QCA alx ethernet driver
Date: Wed, 15 Aug 2012 05:39:11 +0000
Message-ID: <6349D7A510622448B1BA0967850A84380136A218@NASANEXD02D.na.qualcomm.com>
References: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
	<20120811135044.529a7081@nehalam.linuxnetplumber.net>
	<6349D7A510622448B1BA0967850A84380136A1EF@NASANEXD02D.na.qualcomm.com>
 <20120814.223258.1180104882398843954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>,
	"hao-ran.liu@canonical.com" <hao-ran.liu@canonical.com>,
	"joe@perches.com" <joe@perches.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:18295 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab2HOFjN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 01:39:13 -0400
In-Reply-To: <20120814.223258.1180104882398843954.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller [mailto:davem@davemloft.net]
Sent: Wednesday, August 15, 2012 1:33 PM

>From: "Ren, Cloud" <cjren@qca.qualcomm.com>
>Date: Wed, 15 Aug 2012 03:29:26 +0000
>
>>>> +	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
>>>> ...
>>>> +	strcpy(netdev->name, "eth%d");
>>>> +	retval = register_netdev(netdev);
>>>
>>>The strcpy is unnecessary, alloc_etherdev already sets that.
>>
>> The strcpy is useful. netdev->name is set as pci_name in front. So the strcpy
>restores it.
>
>Are you doing this just to influence the initial driver log messages?

 Yes.

>
>Don't do that, it's gross.

Ok, I will remove it.
