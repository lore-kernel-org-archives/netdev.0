From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH v2 1/3] ixgbe: Specify rx hash type
 wrt rx	desc RSS type
Date: Wed, 6 May 2015 22:45:29 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E17F8289B0@ORSMSX108.amr.corp.intel.com>
References: <1430276261-29821-1-git-send-email-fan.du@intel.com>
 <1430276261-29821-2-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Du, Fan" <fan.du@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Du, Fan" <fan.du@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45658 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbbEFWpb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 18:45:31 -0400
In-Reply-To: <1430276261-29821-2-git-send-email-fan.du@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Fan Du
> Sent: Tuesday, April 28, 2015 7:58 PM
> To: Kirsher, Jeffrey T
> Cc: netdev@vger.kernel.org; Du, Fan; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [PATCH v2 1/3] ixgbe: Specify rx hash type wrt rx desc
> RSS type
> 
> RSS could be leveraged by taking account L4 src/dst ports as ingredients, thus
> ingress skb rx hash type should honor such the real configuration.
> 
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   25 +++++++++++++++++++++-
> ---
>  1 files changed, 21 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index d3f4b0c..5df896b 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
