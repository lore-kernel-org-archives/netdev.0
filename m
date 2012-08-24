From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH v2] net: add new QCA alx ethernet driver
Date: Fri, 24 Aug 2012 03:09:44 +0100
Message-ID: <1345774184.2579.51.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345480949-14800-1-git-send-email-cjren@qca.qualcomm.com>
	 <20120822.225700.714020017287504609.davem@davemloft.net>
	 <157393863283F442885425D2C45428562A4F5169@nasanexd02f.na.qualcomm.com>
	 <1345756142.2579.16.camel@bwh-desktop.uk.solarflarecom.com>
	 <157393863283F442885425D2C45428562A4F54E3@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <157393863283F442885425D2C45428562A4F54E3@nasanexd02f.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-08-24 at 01:55 +0000, Huang, Xiong wrote:
> Thanks for all your feedback. I have another question need your help.
> 
> This NIC has special function that could receive/transmit simple
> packet when it's in sleep (D3) state.
> It will help someone wakeup his/her machine even it's behind a router.
> This function is disabled by default. To enable it, the NIC should be
> configured by app.
> My question is which interface can I select to configure(write to) the
> NIC register ?

There are standard operations to configure Wake-on-LAN (commands
ETHTOOL_{G,S}WOL, driver methods ethtool_ops::{get,set}_wol) and WOL
modes including MagicPacket.

If you want to implement a more sophisticated packet matching mode that
requires more details than struct ethtool_wolinfo, then you may need to
define new operations.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
