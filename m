From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [PATCH 2/2] net: define feature flags for FCoE offloads
Date: Mon, 6 Oct 2008 16:13:39 -0700
Message-ID: <85B0945B2DB96C40BE3F762205A682ED03D44092@orsmsx420.amr.corp.intel.com>
References: <20081006220524.3308.64889.stgit@zyfc9ini.jf.intel.com> <20081006220926.3308.48505.stgit@zyfc9ini.jf.intel.com> <1223332642.3984.94.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41119 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106AbYJFXOE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 19:14:04 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1223332642.3984.94.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> +#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
>> +
>>  	/* Segmentation offload features */
>>  #define NETIF_F_GSO_SHIFT	16
>>  #define NETIF_F_GSO_MASK	0xffff0000
>[...]
>
>NETIF_F_FCOE_CRC shouldn't be included in NETIF_F_GSO_MASK.
>
>Ben.
>
I apologize for this patch as one patch to claim the a few bits back
from SKB_GSO_MASK was missing here in the original series. I shall
resubmit the complete series to have all patches included, plus fixing
the style issue in the first patch. 

Thanks.

yi
