From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [next PATCH 07/11] ixgbe: Reorder search to
 work from the top down instead of bottom up
Date: Thu, 10 Dec 2015 22:53:10 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E180CF61B0@ORSMSX108.amr.corp.intel.com>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
 <20151103011007.28233.6659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58825 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbbLJWxM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 17:53:12 -0500
In-Reply-To: <20151103011007.28233.6659.stgit@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Alexander Duyck
> Sent: Monday, November 02, 2015 5:10 PM
> To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [next PATCH 07/11] ixgbe: Reorder search to work
> from the top down instead of bottom up
> 
> This patch is meant to reduce the complexity of the search function used for
> finding a VLVF entry associated with a given VLAN ID.  The previous code was
> searching from bottom to top.  I reordered it to search from top to bottom.  In
> addition I pulled an AND statement out of the loop and instead replaced it with
> an OR statement outside the loop.  This should help to reduce the overall size
> and complexity of the function.
> 
> There was also some formatting I cleaned up in regards to whitespace and such.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
