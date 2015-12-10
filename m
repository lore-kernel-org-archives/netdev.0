From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [next PATCH 01/11] ixgbe: Return error on
 failure to allocate mac_table
Date: Thu, 10 Dec 2015 22:51:49 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E180CF612A@ORSMSX108.amr.corp.intel.com>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
 <20151103010929.28233.47017.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40551 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbbLJWvv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 17:51:51 -0500
In-Reply-To: <20151103010929.28233.47017.stgit@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Alexander Duyck
> Sent: Monday, November 02, 2015 5:09 PM
> To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [next PATCH 01/11] ixgbe: Return error on failure to
> allocate mac_table
> 
> Add a check to make certain mac_table was actually allocated and is not NULL.
> If it is NULL return -ENOMEM and allow the probe routine to fail rather then
> causing a NULL pointer dereference further down the line.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
