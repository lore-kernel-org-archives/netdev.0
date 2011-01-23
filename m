From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [net-2.6 PATCH 1/2] net: dcbnl: remove redundant
 DCB_CAP_DCBX_STATIC bit
Date: Sun, 23 Jan 2011 18:53:20 +0200
Message-ID: <1295801600.25104.13.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <20110122023512.4239.40379.stgit@jf-dev1-dcblab>
 <4D3A465F.8020809@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2033 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755Ab1AWO4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jan 2011 09:56:41 -0500
In-Reply-To: <4D3A465F.8020809@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2011-01-21 at 18:52 -0800, John Fastabend wrote:
> On 1/21/2011 6:35 PM, John Fastabend wrote:
> > Remove redundant DCB_CAP_DCBX_STATIC bit in DCB capabilities
> > 
> > Setting this bit indicates that no embedded DCBx engine is
> > present and the hardware can not be configured. This is the
> > same as having none of the DCB capability flags set or simply
> > not implementing the dcbnl ops at all.
> > 
> > This patch removes this bit. The bit has not made a stable
> > release yet so removing it should not be an issue with
> > existing apps.
> > 
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > CC: Shmulik Ravid <shmulikr@broadcom.com>
> > ---
> > 
> 
> Shmulik, could you ACK this because you added these bits? But
> I was adding support for this in lldpad and I see no reason that
> we need these?
> 
DCB_CAP_DCBX_STATIC means that the embedded engine will turn the user
configuration into the operational configuration without performing the
actual negotiation, so it is not equivalent to not having an embedded
DCBx engine. This is mostly a debug and integration option as it allows
you to do DCB related or dependent testing and development without
having a proper DCBx peer.

On second thought, I'm not sure this option is justified although we
found it useful during our development. If you think it's not useful
enough (or not at all) then by all means remove it.

Thanks,
Shmulik



