From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: add new QCA alx ethernet driver
Date: Sat, 11 Aug 2012 13:50:44 -0700
Message-ID: <20120811135044.529a7081@nehalam.linuxnetplumber.net>
References: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <qca-linux-team@qualcomm.com>,
	<nic-devel@qualcomm.com>, Xiong Huang <xiong@qca.qualcomm.com>,
	"Hao-Ran Liu(Joseph Liu)" <hao-ran.liu@canonical.com>,
	Joe Perches <joe@perches.com>,
	"Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
To: <cjren@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Aug 2012 18:14:30 +0800
<cjren@qca.qualcomm.com> wrote:

> +	strcpy(netdev->name, "eth%d");
> +	retval = register_netdev(netdev);

The strcpy is unnecessary, alloc_etherdev already sets that.
