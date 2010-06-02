From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] cls_u32: use skb_header_pointer() to dereference
 data safely
Date: Wed, 02 Jun 2010 07:33:10 -0700 (PDT)
Message-ID: <20100602.073310.146112379.davem@davemloft.net>
References: <1275488718-19588-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36835
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757893Ab0FBOdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:33:01 -0400
In-Reply-To: <1275488718-19588-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed,  2 Jun 2010 22:25:18 +0800

> use skb_header_pointer() to dereference data safely
> 
> the original skb->data dereference isn't safe, as there isn't any skb->len or
> skb_is_nonlinear() check. skb_header_pointer() is used instead in this patch.
> And when the skb isn't long enough, we terminate the function u32_classify()
> immediately with -1.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Looks good, applied.
