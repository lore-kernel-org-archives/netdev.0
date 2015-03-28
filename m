From: Grant Likely <grant.likely@linaro.org>
Subject: Re: [PATCH] of_net: factor out repetitive code
 =?iso-8859-1?Q?from=0D?= of_get_mac_address()
Date: Sat, 28 Mar 2015 13:27:48 +0000
Message-ID: <20150328132748.2DDA7C409FF@trevor.secretlab.ca>
References: <1776166.J84mUn2Yu8@wasted.cogentembedded.com>
	<20150318.152933.636562640494674435.davem@davemloft.net>
Cc: robh+dt@kernel.org, devicetree@vger.kernel.org,
	f.fainelli@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:35900 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbbC1OvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 10:51:06 -0400
Received: by wgra20 with SMTP id a20so126928346wgr.3
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2015 07:51:05 -0700 (PDT)
In-Reply-To: <20150318.152933.636562640494674435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Mar 2015 15:29:33 -0400 (EDT)
, David Miller <davem@davemloft.net>
 wrote:
> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Date: Wed, 18 Mar 2015 22:25:46 +0300
> 
> > of_get_mac_address() basically does the same  thing thrice, every  time with  a
> > different  property  name,  so it makes sense to factor out the repetitive code
> > into separate function. While at it, we can start using ETH_ALEN instead of the
> > bare number and drop unnecessary parens around the property length check.
> > 
> > The resulting ARM object file is 100 bytes less in size than before the patch.
> > 
> > Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> > 
> > ---
> > The patch is against Grant Likely's 'linux.git' repo's 'devicetree/next' branch.
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Applied for v4.1, thanks.

g.
