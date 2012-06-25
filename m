From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [RFC net-next (v2) 14/14] ixgbevf: set maximal number of
 default RSS queues
Date: Mon, 25 Jun 2012 21:28:07 +0300
Message-ID: <1340648887.2486.29.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
 <1340624745-8650-15-git-send-email-yuvalmin@broadcom.com>
 <4FE88794.9090704@intel.com>
 <1340639591.2486.25.camel@lb-tlvb-eilong.il.broadcom.com>
 <4FE892CD.1020804@intel.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Greg Rose" <gregory.v.rose@intel.com>
To: "Alexander Duyck" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2611 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754092Ab2FYS21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 14:28:27 -0400
In-Reply-To: <4FE892CD.1020804@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-25 at 09:33 -0700, Alexander Duyck wrote:
> I suggest you locate where we set "adapter->num_rx_queues" and attempt
> to address the issue there.

I see what you mean. On one hand, you use the num_rx_queues as if it can
get higher numbers and the code seems to be ready for that with all the
for loops in place, but on the other hand, it is hard coded to 1 at
ixgbevf_set_num_queues and it seems weird to add min function with
explicit '1'. Do you suggest to leave this driver alone hoping that if
in the future the '1' will change the author will remember to use the
default value?

Thanks,
Eilon
