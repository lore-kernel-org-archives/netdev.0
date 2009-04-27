From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: wrong hash value for temporary SA
Date: Mon, 27 Apr 2009 02:59:19 -0700 (PDT)
Message-ID: <20090427.025919.97824807.davem@davemloft.net>
References: <49F18C9A.40207@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46683
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758092AbZD0J70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:59:26 -0400
In-Reply-To: <49F18C9A.40207@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Fri, 24 Apr 2009 11:55:38 +0200

> When kernel inserts a temporary SA for IKE, it uses the wrong hash
> value for dst
> list. Two hash values were calcultated before: one with source address
> and one
> with a wildcard source address.
> 
> Bug hinted by Junwei Zhang <junwei.zhang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

My bad.

Thanks for fixing this!

Applied.
