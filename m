From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH v1 net-next 1/2] igb: add PHY support for Broadcom 5461S
Date: Sat, 2 May 2015 01:45:39 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B78DBCFF2@ORSMSX101.amr.corp.intel.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
 <553E5979.6090009@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Alan Liebthal <alanl@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:55240 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270AbbEBBpl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 21:45:41 -0400
In-Reply-To: <553E5979.6090009@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Jonathan Toppins
> Sent: Monday, April 27, 2015 8:45 AM
> To: Kirsher, Jeffrey T
> Cc: Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald
> C; Vick, Matthew; Ronciak, John; Williams, Mitch A; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org; gospo@cumulusnetworks.com;
> shm@cumulusnetworks.com; Alan Liebthal
> Subject: Re: [PATCH v1 net-next 1/2] igb: add PHY support for Broadcom
> 5461S
> 
> On 4/17/15 4:23 PM, Jonathan Toppins wrote:
> > From: Alan Liebthal <alanl@cumulusnetworks.com>
> >
> > The Quanta LY8 Ethernet management port uses a Broadcom 5461S chip for
> > the PHY layer. This adds support for this PHY to the Intel igb driver.
> >
> > Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
> > Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> > ---
> >   drivers/net/ethernet/intel/igb/e1000_82575.c   |   20 +++++-
> >   drivers/net/ethernet/intel/igb/e1000_defines.h |    1 +
> >   drivers/net/ethernet/intel/igb/e1000_hw.h      |    1 +
> >   drivers/net/ethernet/intel/igb/e1000_phy.c     |   79
> ++++++++++++++++++++++++
> >   drivers/net/ethernet/intel/igb/e1000_phy.h     |    2 +
> >   5 files changed, 102 insertions(+), 1 deletion(-)
> >
I don't have access to the Broadcom 5461s, but will assume Jonathan / Alan checked this on it on their end.  My set of regression systems did not have any problems with this, so...

Tested-by: Aaron Brown <aaron.f.brown@intel.com>

...
... 
> Simple keepalive to make sure these have not been forgotten, the
> patchworks entries are still in "new" state.
> 
> http://patchwork.ozlabs.org/patch/462222/
> http://patchwork.ozlabs.org/patch/462223/
> 
> Regards,
> -Jon

Nope, not forgotten, I've just been really busy with other things.  I'll take a closer look at that other patch (2/2) next early next week.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
