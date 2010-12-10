From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] xfrm: ESP Traffic Flow Confidentiality padding (v3)
Date: Fri, 10 Dec 2010 14:44:22 -0800 (PST)
Message-ID: <20101210.144422.52203130.davem@davemloft.net>
References: <1291819071-17538-1-git-send-email-martin@strongswan.org>
	<20101209124732.GA28931@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin@strongswan.org, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58114
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751559Ab0LJWny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 17:43:54 -0500
In-Reply-To: <20101209124732.GA28931@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 9 Dec 2010 20:47:32 +0800

> On Wed, Dec 08, 2010 at 03:37:48PM +0100, Martin Willi wrote:
>> The following patchset adds Traffic Flow Confidentiality padding. The
>> first patch introduces a new Netlink XFRM attribute to configure TFC via
>> userspace. Patch two and three implement the padding logic in IPv4 and
>> IPv6 ESP. Padding is always done using the RFC4303 format an is clamped
>> to the PMTU.
>> 
>> Changes from v2:
>>   - Remove unused flag field in attribute, use a plain u32 as attribute payload
>>   - Reject installation of TFC padding on non-tunnel SAs
> 
> Looks good to me.  Thanks for the hard work Martin!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

All applied, thanks everyone!
