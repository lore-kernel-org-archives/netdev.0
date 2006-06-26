From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skb_find_text ignores to argument
Date: Mon, 26 Jun 2006 00:01:09 -0700 (PDT)
Message-ID: <20060626.000109.55508339.davem@davemloft.net>
References: <20060625145200.GA32074@linuxace.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21403
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751286AbWFZHBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 03:01:11 -0400
To: kernel@linuxace.com
In-Reply-To: <20060625145200.GA32074@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Oester <kernel@linuxace.com>
Date: Sun, 25 Jun 2006 07:52:00 -0700

> skb_find_text takes a "to" argument which is supposed to limit how
> far into the skb it will search for the given text.  At present,
> it seems to ignore that argument on the first skb, and instead
> return a match even if the text occurs beyond the limit.
> 
> Patch below fixes this, after adjusting for the "from" starting
> point.  This consequently fixes the netfilter string match's "--to"
> handling, which currently is broken.
> 
> Signed-off-by: Phil Oester <kernel@linuxace.com>

Looks good, applied.

Thanks Phil.
