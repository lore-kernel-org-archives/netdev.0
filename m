From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-2.6 PATCH 1/2] net: dcbnl: remove redundant DCB_CAP_DCBX_STATIC
 bit
Date: Fri, 21 Jan 2011 18:52:15 -0800
Message-ID: <4D3A465F.8020809@intel.com>
References: <20110122023512.4239.40379.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"shmulikr@broadcom.com" <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33740 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754210Ab1AVCwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 21:52:17 -0500
In-Reply-To: <20110122023512.4239.40379.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/21/2011 6:35 PM, John Fastabend wrote:
> Remove redundant DCB_CAP_DCBX_STATIC bit in DCB capabilities
> 
> Setting this bit indicates that no embedded DCBx engine is
> present and the hardware can not be configured. This is the
> same as having none of the DCB capability flags set or simply
> not implementing the dcbnl ops at all.
> 
> This patch removes this bit. The bit has not made a stable
> release yet so removing it should not be an issue with
> existing apps.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> CC: Shmulik Ravid <shmulikr@broadcom.com>
> ---
> 

Shmulik, could you ACK this because you added these bits? But
I was adding support for this in lldpad and I see no reason that
we need these?

Thanks,
John.
