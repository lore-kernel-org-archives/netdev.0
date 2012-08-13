From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH] net: add new QCA alx ethernet driver
Date: Mon, 13 Aug 2012 01:19:24 +0000
Message-ID: <157393863283F442885425D2C4542856282E0637@nasanexd02f.na.qualcomm.com>
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
	"Hao-Ran Liu(Joseph Liu)" <hao-ran.liu@canonical.com>,
	Joe Perches <joe@perches.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:20925 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767Ab2HMBT1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 21:19:27 -0400
In-Reply-To: <20120811135044.529a7081@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Sunday, August 12, 2012 4:51
> To: Ren, Cloud
> > +	strcpy(netdev->name, "eth%d");
> > +	retval = register_netdev(netdev);
> 
> The strcpy is unnecessary, alloc_etherdev already sets that.

Thanks, Hemminger, we will remove this line in the next post.

-Xiong
