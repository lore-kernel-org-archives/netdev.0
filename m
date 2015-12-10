From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [next PATCH 11/11] ixgbe: Clean stale VLANs
 when changing port vlan or resetting
Date: Thu, 10 Dec 2015 22:54:07 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E180CF6220@ORSMSX108.amr.corp.intel.com>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
 <20151103011032.28233.6892.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:36024 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623AbbLJWyJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 17:54:09 -0500
In-Reply-To: <20151103011032.28233.6892.stgit@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Alexander Duyck
> Sent: Monday, November 02, 2015 5:11 PM
> To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [next PATCH 11/11] ixgbe: Clean stale VLANs when
> changing port vlan or resetting
> 
> This patch guarantees that the VFs do not have access to VLANs that they were
> not supposed to.  What this patch does is add code so that we delete the
> previous port VLAN after adding a new one, and if we reset the VF we clear all of
> the filters associated with it.
> 
> Previously the code was leaving all previous VLANs mapped to the VF and they
> didn't get deleted unless the VF specifically requested it or if the PF itself was
> reset.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
