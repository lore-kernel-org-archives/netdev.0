From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net: Convert ethtool {get_stats,self_test}_count()
 ops to get_sset_count()
Date: Mon, 05 Oct 2009 00:12:50 -0700 (PDT)
Message-ID: <20091005.001250.27034908.davem@davemloft.net>
References: <1254432754.2735.27.camel@achroite>
	<1254668841.2642.3.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, chien.tin.tung@intel.com,
	faisal.latif@intel.com, subbus@serverengines.com,
	sathyap@serverengines.com, benh@kernel.crashing.org,
	jwboyer@linux.vnet.ibm.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54637
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758497AbZJEHM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:12:56 -0400
In-Reply-To: <1254668841.2642.3.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Sun, 4 Oct 2009 17:07:21 +0200

> On Thu, 2009-10-01 at 14:32 -0700, Ben Hutchings wrote:
>> These string query operations were supposed to be replaced by the
>> generic get_sset_count() starting in 2007.  Convert the remaining
>> implementations.
>> 
>> Also remove calls to these operations to initialise drvinfo->n_stats.
>> The ethtool core code already does that.
>> 
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>> ---
>>  drivers/infiniband/hw/nes/nes_nic.c |   12 ++++---
>>  drivers/net/benet/be_ethtool.c      |   11 +++++--
>>  drivers/net/bnx2x_main.c            |   60 ++++++++++++++++++-----------------
>>  drivers/net/ibm_newemac/core.c      |   10 +++--
>>  drivers/net/igbvf/ethtool.c         |   25 +++++++-------
>>  drivers/net/niu.c                   |    7 +++-
>>  6 files changed, 70 insertions(+), 55 deletions(-)
>> 
> Thanks Ben, bnx2x tested and works just fine with this patch.
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied to net-next-2.6
