From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: add new QCA alx ethernet driver
Date: Wed, 15 Aug 2012 08:02:26 -0700
Message-ID: <20120815080226.388ea856@nehalam.linuxnetplumber.net>
References: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
	<20120811135044.529a7081@nehalam.linuxnetplumber.net>
	<6349D7A510622448B1BA0967850A84380136A1EF@NASANEXD02D.na.qualcomm.com>
	<20120814.223258.1180104882398843954.davem@davemloft.net>
	<6349D7A510622448B1BA0967850A84380136A218@NASANEXD02D.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>,
	"hao-ran.liu@canonical.com" <hao-ran.liu@canonical.com>,
	"joe@perches.com" <joe@perches.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6349D7A510622448B1BA0967850A84380136A218@NASANEXD02D.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Aug 2012 05:39:11 +0000
"Ren, Cloud" <cjren@qca.qualcomm.com> wrote:

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, August 15, 2012 1:33 PM
> 
> >From: "Ren, Cloud" <cjren@qca.qualcomm.com>
> >Date: Wed, 15 Aug 2012 03:29:26 +0000
> >
> >>>> +	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
> >>>> ...
> >>>> +	strcpy(netdev->name, "eth%d");
> >>>> +	retval = register_netdev(netdev);
> >>>
> >>>The strcpy is unnecessary, alloc_etherdev already sets that.
> >>
> >> The strcpy is useful. netdev->name is set as pci_name in front. So the strcpy
> >restores it.
> >
> >Are you doing this just to influence the initial driver log messages?
> 
>  Yes.
> 
> >
> >Don't do that, it's gross.
> 
> Ok, I will remove it.

Before the driver is registered, use dev_info() type of logging.
