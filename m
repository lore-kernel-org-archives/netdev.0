From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [PATCH net-next 2/3] dcbnl: adding DCBX feature flags
 get-set
Date: Wed, 29 Dec 2010 16:05:53 +0200
Message-ID: <1293631553.29378.30.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <1292959973.7142.131.camel@lb-tlvb-shmulik.il.broadcom.com>
 <4D1A7D85.2030709@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Liu, Lucy" <lucy.liu@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4047 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693Ab0L2OGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 09:06:11 -0500
In-Reply-To: <4D1A7D85.2030709@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2010-12-28 at 16:15 -0800, John Fastabend wrote:
> On 12/21/2010 11:32 AM, Shmulik Ravid wrote:
> > Adding a pair of set-get functions to dcbnl for setting the negotiation
> > flags of the various DCB features. The user sets these flags (enable,
> > advertise, willing) for each feature to be used by the device DCBX
> > engine. The 'get' routine returns which of the features is enabled
> > after the negotiation.
> > 
> > Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Dave, these are going to conflict with my patches
> 
> [net-next-2.6,1/3] dcbnl: add support for ieee8021Qaz attributes
> [net-next-2.6,2/3] dcbnl: add appliction tlv handlers
> 
> If needed either Shmulik or myself can work out the conflicts if you want a single series that applies cleanly.
> 
> Thanks,
> John.

John, 

Since I need to modify my patches I can resubmit them on top of your
patches above so that they would need to be applied after yours are. Is
this a good way to resolve the conflicts ?

Thanks,
Shmulik  


