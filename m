From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Subject: RE: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161
 Ethernet driver
Date: Wed, 19 Oct 2011 07:53:53 +0000
Message-ID: <6349D7A510622448B1BA0967850A8438011CBAB1@nasanexd02d.na.qualcomm.com>
References: <1319009213-20627-1-git-send-email-cloud.ren@atheros.com>
	<20111019.033324.1233460304204609569.davem@davemloft.net>
	<6349D7A510622448B1BA0967850A8438011CBA5D@nasanexd02d.na.qualcomm.com>
 <20111019.035000.931404890148181821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rodriguez, Luis" <rodrigue@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111019.035000.931404890148181821.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I got it. Thanks.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, October 19, 2011 3:50 PM
To: Ren, Cloud
Cc: Rodriguez, Luis; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver

From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Date: Wed, 19 Oct 2011 07:44:02 +0000

> Ok. What logging interfaces can I use? Are they dev_err, dev_info and 
> dev_warn ? thanks

netif_*(), they check netif_msg_*() to see if the particular kind of logging message is enabled or not, and this can be set dynamically if you code your driver to properly set netdev->msg_enable.

Use other drivers as examples.
