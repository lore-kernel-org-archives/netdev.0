From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
 destructor
Date: Mon, 5 May 2008 12:43:25 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805051241240.21115@wrl-59.cs.helsinki.fi>
References: <1209925940.3655.17.camel@johannes.berg>
 <20080505.002006.225975612.davem@davemloft.net> <1209972675.3655.15.camel@johannes.berg>
 <20080505.004017.247102504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37905 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbYEEJnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 05:43:31 -0400
In-Reply-To: <20080505.004017.247102504.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 May 2008, David Miller wrote:

> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Mon, 05 May 2008 09:31:15 +0200
> 
> > If we decide to uninline those functions for another reason (used too
> > much, code size, ...) then we can still do that.
> 
> Agreed.

According to my measurements the size bloat of those two is
(x86/32bit, gcc 4.1.2 redhat something):

-1091  40 funcs, 89 +, 1180 -, diff: -1091 --- skb_set_owner_r
-495  46 funcs, 70 +, 565 -, diff: -495 --- skb_set_owner_w

-- 
 i.
