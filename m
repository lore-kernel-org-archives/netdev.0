From: "Love, Robert W" <robert.w.love@intel.com>
Subject: RE: [PATCH] net: Add the FCoE Initialization Protocol ethertype
Date: Fri, 1 May 2009 15:57:19 -0700
Message-ID: <273D38FBE7C6FE46A1689FCD014A0B8B495C0130@azsmsx505.amr.corp.intel.com>
References: <20090501185532.14602.21059.stgit@fritz>
	<20090501.150454.224636608.davem@davemloft.net>
	<273D38FBE7C6FE46A1689FCD014A0B8B495C012C@azsmsx505.amr.corp.intel.com>
 <20090501.155601.205697782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5238 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbZEAW5V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:57:21 -0400
In-Reply-To: <20090501.155601.205697782.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Love, Robert W" <robert.w.love@intel.com>
> Date: Fri, 1 May 2009 15:53:32 -0700
> 
>> The FIP implementation is upstream, in drivers/scsi/libfcoe.c.
>> There is a local define in include/scsi/fc/fc_fip.h for ETH_P_FCOE
>> and I'd rather move it to the propper location.
> 
> Then add that local definition removal to your patch so there is
> no mystery about what this is used for.
> 
>> I can refresh this patch to include the fc_fip.h removal and you and
>> James can decide who takes the patch if that's a better aproach.
> 
> That works much better, and to avoid merge issues you can send it
> via James with my pre-ack:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Will do, thanks.