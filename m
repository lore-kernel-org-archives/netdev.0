From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bnx2x: off by one in bnx2x_ets_e3b0_sp_pri_to_cos_set()
Date: Thu, 19 Apr 2012 15:23:15 -0400 (EDT)
Message-ID: <20120419.152315.1499384529431466518.davem@davemloft.net>
References: <20120418065342.GC12831@elgon.mountain>
	<1334741227.12363.5.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756250Ab2DSTXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 15:23:21 -0400
In-Reply-To: <1334741227.12363.5.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 18 Apr 2012 12:27:07 +0300

> On Wed, 2012-04-18 at 09:53 +0300, Dan Carpenter wrote:
>> The sp_pri_to_cos[] array size depends on the config but lets say it is
>> BX_E3B0_MAX_NUM_COS_PORT0 and max_num_of_cos is also
>> DCBX_E3B0_MAX_NUM_COS_PORT0.  In the original code
>> "pri == max_num_of_cos" was accepted but it is one past the end of the
>> array.
>> 
>> Also we used "pri" before capping it.  It's a harmless read past the end
>> of the array, but it would affect which error message gets printed.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> 
> 
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks everyone.
