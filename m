From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add new QCA alx ethernet driver which supercedes
 atl1c
Date: Tue, 28 Feb 2012 20:58:13 -0500 (EST)
Message-ID: <20120228.205813.1504449700643199024.davem@davemloft.net>
References: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com>
	<1330480210-30470-2-git-send-email-rodrigue@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mcgrof@frijolero.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, kgiori@qca.qualcomm.com,
	chris.snook@gmail.com, mathieu@qca.qualcomm.com,
	bryanh@quicinc.com, steventl@qca.qualcomm.com,
	hao-ran.liu@canonical.com, cjren@qca.qualcomm.com, joe@perches.com
To: rodrigue@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330480210-30470-2-git-send-email-rodrigue@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Date: Tue, 28 Feb 2012 17:50:10 -0800

> QCA is commiting on fixing all bugs upstream on this driver.

By implication QCA is not willing to fix bugs in and properly
maintain the existing in-tree atl1c driver.

We're not going to wholesale replace an entire driver in this
way, and you should know better Luis.

Please research the history of the Broadcom TG3 driver, Jeff Garzik
and myself wrote a driver for Linux ignoring Broadcom's out of tree
driver completely.

Several times Broadcom tried to just plunk their out-of-tree driver,
however properly cleaned up, into the tree.  We considerd that
unacceptable and pushed back until they started instead making gradual
improvements and fixes to the driver Jeff and myself wrote and had in
the tree already.  And they did.

We expect Qualcomm to follow this precedent, and I will push back
strongly on any attempt to just replace the existing driver.
