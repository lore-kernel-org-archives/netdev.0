From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCHv2 00/11]Get rid of all the old macro DMA_nBIT_MASK and
 use DMA_BIT_MASK(n) instead
Date: Thu, 19 Feb 2009 13:47:50 +0100
Message-ID: <499D54F6.7000108@s5r6.in-berlin.de>
References: <499CFDC8.1070600@cn.fujitsu.com> <499D0221.9090407@cn.fujitsu.com> <20090219081403.GA5400@elte.hu> <499D1ED9.4040005@cn.fujitsu.com> <499D2728.1080208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:40623 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbZBSMr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 07:47:59 -0500
In-Reply-To: <499D2728.1080208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang wrote:
> v1->v2:fix s/micro/macro typo and keep the old defines
>             of DMA_nBIT_MASK
> ----------------------
> Replace all DMA_nBIT_MASK macro with the new DMA_BIT_MASK(n) macro
> 
> 01:Replace all DMA_64BIT_MASK macro with DMA_BIT_MASK(64)
> 02:Replace all DMA_48BIT_MASK macro with DMA_BIT_MASK(48)
> 03:Replace all DMA_40BIT_MASK macro with DMA_BIT_MASK(40)
> 04:Replace all DMA_39BIT_MASK macro with DMA_BIT_MASK(39)
> 05:Replace all DMA_35BIT_MASK macro with DMA_BIT_MASK(35)
> 06:Replace all DMA_32BIT_MASK macro with DMA_BIT_MASK(32)
> 07:Replace all DMA_31BIT_MASK macro with DMA_BIT_MASK(31)
> 08:Replace all DMA_30BIT_MASK macro with DMA_BIT_MASK(30)
> 09:Replace all DMA_28BIT_MASK macro with DMA_BIT_MASK(28)
> 10:Replace all DMA_24BIT_MASK macro with DMA_BIT_MASK(24)
> 11:Update the old macro DMA_nBIT_MASK related documentations
> 

Shouldn't you organize the patch series per subsystem, not per old
macro?  And then Cc the respective maintainers?

As it stands, the patches cannot be routed through the normal channels;
yet there is no fundamental reason to handle these patches differently
from normal patches.
-- 
Stefan Richter
-=====-==--= --=- =--==
http://arcgraph.de/sr/
