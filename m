From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: fix a race in xfrm_state_lookup_byspi
Date: Thu, 30 Apr 2015 12:24:50 +0200
Message-ID: <20150430102450.GO8928@secunet.com>
References: <1430268164-19019-1-git-send-email-roy.qing.li@gmail.com>
 <5A90DA2E42F8AE43BC4A093BF0678848E4D693@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "roy.qing.li@gmail.com" <roy.qing.li@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Du, Fan" <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46858 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750749AbbD3KYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 06:24:54 -0400
Content-Disposition: inline
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF0678848E4D693@SHSMSX104.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 05:25:25AM +0000, Du, Fan wrote:
> 
> >-----Original Message-----
> >From: roy.qing.li@gmail.com [mailto:roy.qing.li@gmail.com]
> >Sent: Wednesday, April 29, 2015 8:43 AM
> >To: netdev@vger.kernel.org
> >Cc: Du, Fan; steffen.klassert@secunet.com
> >Subject: [PATCH] xfrm: fix a race in xfrm_state_lookup_byspi
> >
> >From: Li RongQing <roy.qing.li@gmail.com>
> >
> >The returned xfrm_state should be hold before unlock xfrm_state_lock,
> >otherwise the returned xfrm_state maybe be released.
> >
> >Fixes: c454997e6[{pktgen, xfrm} Introduce xfrm_state_lookup_byspi..]
> >Cc: Fan Du <fan.du@intel.com>
> >Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> 
> Acked-by: Fan Du <fan.du@intel.com>

Applied to the ipsec tree, thanks a lot!
