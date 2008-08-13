From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rearrange structure xfrm_userpolicy_type in
 linux/xfrm.h
Date: Wed, 13 Aug 2008 01:39:49 -0700 (PDT)
Message-ID: <20080813.013949.193697827.davem@davemloft.net>
References: <c4ee36230808130056s7d01ebaeh677593ef7c099985@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tisphie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51851
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755716AbYHMIjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 04:39:48 -0400
In-Reply-To: <c4ee36230808130056s7d01ebaeh677593ef7c099985@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Park Ji-In" <tisphie@gmail.com>
Date: Wed, 13 Aug 2008 16:56:32 +0900

> struct xfrm_userpolicy_type in linux/xfrm.h is something strange,
> It seems that to align 4byte, but it's size in x86 with gcc is 6byte.
> rearrange to fit in 4byte structure
> 
> Signed-off-by: Park Jiin <tisphie@gmail.com>

You can't change this structure as it's exported to userspace and
therefore part of many already compiled userland binaries out there.
