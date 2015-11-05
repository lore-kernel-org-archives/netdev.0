From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH v6] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Thu, 5 Nov 2015 00:01:05 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFAEB02@fmsmsx115.amr.corp.intel.com>
References: <20151104232100.GJ14575@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31699 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932288AbbKEABI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 19:01:08 -0500
In-Reply-To: <20151104232100.GJ14575@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com]
> Sent: Wednesday, November 04, 2015 3:21 PM
> 
> This is the i40e equivalent of commit c762dff24c06 ("ixgbe: Look up MAC
> address in Open Firmware or IDPROM").
> 
> As with that fix, attempt to look up the MAC address in Open Firmware
> on systems that support it, and use IDPROM on SPARC if no OF address
> is found.
> 
> In the case of the i40e there is an assumption that the default mac
> address has already been set up as the primary mac filter on probe,
> so if this filter is obtained from the Open Firmware or IDPROM, an
> explicit write is needed via i40e_aq_mac_address_write() and
> i40e_aq_add_macvlan() invocation.
> 
> Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2, v3: Andy Shevchenko comments
> v4: Shannon Nelson review: explicitly set up mac filters before
> register_netdev
> v5: Shannon Nelson code style comments
> v6: Shannon Nelson code style comments
> 
>  drivers/net/ethernet/intel/i40e/i40e_main.c |   83
> ++++++++++++++++++++++++++-
>  1 files changed, 82 insertions(+), 1 deletions(-)
> 

Acked-by: Shannon Nelson <shannon.nelson@intel.com>
