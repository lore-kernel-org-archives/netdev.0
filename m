From: James Morris <jmorris@namei.org>
Subject: Re: call panic if nl_table allocation fails
Date: Wed, 23 Aug 2006 10:06:25 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608231003340.3198@d.namei>
References: <20060823113740.GA7834@miraclelinux.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:27362 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932262AbWHWOG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 10:06:28 -0400
To: Akinobu Mita <mita@miraclelinux.com>
In-Reply-To: <20060823113740.GA7834@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006, Akinobu Mita wrote:

> This patch makes crash happen if initialization of nl_table fails
> in initcalls. It is better than getting use after free crash later.

>  	nl_table = kcalloc(MAX_LINKS, sizeof(*nl_table), GFP_KERNEL);

Perhaps it'd be better to declare this as an array rather than allocating 
it at runtime.



- James
-- 
James Morris
<jmorris@namei.org>
