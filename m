From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] thunderbolt: Right shifting to zero bug
 in tbnet_handle_packet()
Date: Thu, 19 Oct 2017 13:05:07 +0100 (WEST)
Message-ID: <20171019.130507.171332903320471229.davem@davemloft.net>
References: <20171013112959.sc2pwazrpk7fxbtw@mwanda>
        <20171017123301.z6heqexdlo6lc52b@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.jamet@intel.com, amir.jer.levy@intel.com,
        mika.westerberg@linux.intel.com, yehezkel.bernat@intel.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48686 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752890AbdJSMFU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:05:20 -0400
In-Reply-To: <20171017123301.z6heqexdlo6lc52b@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 17 Oct 2017 15:33:01 +0300

> There is a problem when we do:
> 
> 	sequence = pkg->hdr.length_sn & TBIP_HDR_SN_MASK;
> 	sequence >>= TBIP_HDR_SN_SHIFT;
> 
> TBIP_HDR_SN_SHIFT is 27, and right shifting a u8 27 bits is always
> going to result in zero.  The fix is to declare these variables as u32.
> 
> Fixes: e69b6c02b4c3 ("net: Add support for networking over Thunderbolt cable")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
