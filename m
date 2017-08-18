From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v2 2/2] ifcfg: Quote left-hand side of [ ]
 expression
Date: Fri, 18 Aug 2017 09:32:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005A809@AcuExch.aculab.com>
References: <20170817170932.24900-1-phil@nwl.cc>
 <20170817170932.24900-3-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:60915 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750920AbdHRJc5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 05:32:57 -0400
In-Reply-To: <20170817170932.24900-3-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 17 August 2017 18:10
> This prevents word-splitting and therefore leads to more accurate error
> message in case 'grep -c' prints something other than a number.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/ifcfg | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/ifcfg b/ip/ifcfg
> index 083d9df36742f..30a2dc49816cd 100644
> --- a/ip/ifcfg
> +++ b/ip/ifcfg
> @@ -131,7 +131,7 @@ noarp=$?
> 
>  ip route add unreachable 224.0.0.0/24 >& /dev/null
>  ip route add unreachable 255.255.255.255 >& /dev/null
> -if [ `ip link ls $dev | grep -c MULTICAST` -ge 1 ]; then
> +if [ "`ip link ls $dev | grep -c MULTICAST`" -ge 1 ]; then

You could drag all these scripts into the 1990's by using $(...)
instead of `...`.

	David
