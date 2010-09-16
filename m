From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] iputils: arping fails to set correct broadcast address
Date: Thu, 16 Sep 2010 17:28:28 +0900
Message-ID: <4C91D52C.5010109@linux-ipv6.org>
References: <1281692696.23856.37.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 585591@bugs.debian.org,
	Noah Meyerhans <noahm@debian.org>, Paul Martin <pm@debian.org>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46634 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752159Ab0IPIeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 04:34:50 -0400
In-Reply-To: <1281692696.23856.37.camel@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

(4:59), Jesper Dangaard Brouer wrote:
> 
> From: Paul Martin<pm@debian.org>
> 
> There seems to have been introduced a bug in iputils release s20100418.
> 
> This patch is based upon git://www.linux-ipv6.org/gitroot/iputils.git
> (git commit fe342ca3148)
> 
> The regression is caused by commit 56018bf1b3
>   arping: Support link-layer type with larger link-layer address.
> 
> As reported by: Paul Martin<pm@debian.org>  in Debian bugreport #585591.
> 
>   There's a logic error in the function that parses the interface's
>   broadcast address, causing it not to fill the broadcast address array
>   correctly.
> 
> Please apply.
> 
> Reported-by: Paul Martin<pm@debian.org>
> Tested-by: Jesper Dangaard Brouer<hawk@comx.dk>
> Signed-off-by: Jesper Dangaard Brouer<hawk@comx.dk>

Applied.  Thank you very much!

--yoshfuji
