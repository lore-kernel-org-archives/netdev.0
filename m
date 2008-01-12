From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] fix sparse warnings
Date: Sat, 12 Jan 2008 03:28:01 -0800 (PST)
Message-ID: <20080112.032801.91587816.davem@davemloft.net>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.659443238@linux-foundation.org>
	<4788A17D.5070903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35918
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761467AbYALL2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 06:28:01 -0500
In-Reply-To: <4788A17D.5070903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 12 Jan 2008 12:16:13 +0100

>     We could use a better scheme with an extra indirection.

Unfortunately, indirection will likely have a negative
impact upon performance.  We go only as fast as the
number of memory references made by this code.

> 3) 'pos' and 'bits' fields of 'struct tnode' might be converted to
>     plain uchar, instead of 5-bits fields, to reduce complexity for
>     generated code.

This seems reasonable, I'll likely apply this.
