From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [next PATCH 02/11] ixgbe: Fix SR-IOV VLAN
 pool	configuration
Date: Thu, 10 Dec 2015 22:52:00 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E180CF6135@ORSMSX108.amr.corp.intel.com>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
 <20151103010935.28233.72294.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14207 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbbLJWwC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 17:52:02 -0500
In-Reply-To: <20151103010935.28233.72294.stgit@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Alexander Duyck
> Sent: Monday, November 02, 2015 5:10 PM
> To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [next PATCH 02/11] ixgbe: Fix SR-IOV VLAN pool
> configuration
> 
> The code for checking the PF bit in ixgbe_set_vf_vlan_msg was using the wrong
> offset and as a result it was pulling the VLAN off of the PF even if there were VFs
> numbered greater than 40 that still had the VLAN enabled.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
