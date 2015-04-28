From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH v1 net-next 1/3] igb: set driver data for device entries
 that were missing
Date: Tue, 28 Apr 2015 03:17:41 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B78DBB03B@ORSMSX101.amr.corp.intel.com>
References: <1428707018-6405-1-git-send-email-jtoppins@cumulusnetworks.com>
 <553E58E5.9000105@cumulusnetworks.com>
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
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40588 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850AbbD1DRn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 23:17:43 -0400
In-Reply-To: <553E58E5.9000105@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Jonathan Toppins
> Sent: Monday, April 27, 2015 8:42 AM
> To: Kirsher, Jeffrey T
> Cc: Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald
> C; Vick, Matthew; Ronciak, John; Williams, Mitch A; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org; gospo@cumulusnetworks.com;
> shm@cumulusnetworks.com
> Subject: Re: [PATCH v1 net-next 1/3] igb: set driver data for device
> entries that were missing
> 
> On 4/10/15 7:03 PM, Jonathan Toppins wrote:
> > Three of the supported PCI device entries neglected to set driver data
> > to "board_82575". This is not a problem until a new board type is
> > defined, so avoid the potential problem all together.
> >
> > Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> > ---
> >   drivers/net/ethernet/intel/igb/igb_main.c |    6 +++---
> >   1 file changed, 3 insertions(+), 3 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>

Well, regression tested that is as I don't have any of the potential new boards.
