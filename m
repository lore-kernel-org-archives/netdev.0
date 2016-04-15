From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH pci] pci: Add helper function to set VPD size
Date: Fri, 15 Apr 2016 16:25:22 +0000
Message-ID: <BY2PR12MB06481B1A71C47BBDA5E096C4C8680@BY2PR12MB0648.namprd12.prod.outlook.com>
References: <1460657525-17551-1-git-send-email-hariprasad@chelsio.com>
 <00d801d1967c$68e9d100$3abd7300$@opengridcomputing.com>,<571112D2.4010801@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Hariprasad S <hariprasad@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Hannes Reinecke <hare@suse.com>
To: SWise OGC <swise@opengridcomputing.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <571112D2.4010801@opengridcomputing.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Steve Wise <swise@opengridcomputing.com>
| Sent: Friday, April 15, 2016 9:12 AM
|
| On 4/14/2016 1:35 PM, Steve Wise wrote:
| >> The fix is to add a PCI helper function to set the VPD size, so the
| >> driver can expicitly set the exact size of the VPD.
| >>
| >> Fixes commit 104daa71b396 ("PCI: Determine actual VPD size on first
| >> access")
| >>
| >> Signed-off-by: Casey Leedom <leedom@chelsio.com>
| >> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
| > Looks good!
|
| Hey Bjorn,
|
| Will this make the next 4.6-rc?

  Without a fix of some sort, cxgb4 is completely dead in the water as of the 4.6 series.  I'm also worried about the bnx2x driver which seems to be doing something similar to our cxgb4 driver.  (I.e. there isn't just a single VPD Data Structure hosted at the beginning of the VPD Space.)

Casey