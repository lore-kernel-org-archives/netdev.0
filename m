From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 2/3] dcbnl: adding DCBX feature flags get-set
Date: Tue, 28 Dec 2010 16:15:01 -0800
Message-ID: <4D1A7D85.2030709@intel.com>
References: <1292959973.7142.131.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "eilong@broadcom.com" <eilong@broadcom.com>,
	"Liu, Lucy" <lucy.liu@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ravid <shmulikr@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55529 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105Ab0L2APC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Dec 2010 19:15:02 -0500
In-Reply-To: <1292959973.7142.131.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2010 11:32 AM, Shmulik Ravid wrote:
> Adding a pair of set-get functions to dcbnl for setting the negotiation
> flags of the various DCB features. The user sets these flags (enable,
> advertise, willing) for each feature to be used by the device DCBX
> engine. The 'get' routine returns which of the features is enabled
> after the negotiation.
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>

Acked-by: John Fastabend <john.r.fastabend@intel.com>

Dave, these are going to conflict with my patches

[net-next-2.6,1/3] dcbnl: add support for ieee8021Qaz attributes
[net-next-2.6,2/3] dcbnl: add appliction tlv handlers

If needed either Shmulik or myself can work out the conflicts if you want a single series that applies cleanly.

Thanks,
John.





