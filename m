From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fib_trie: rescan if key is lost during dump
Date: Fri, 25 Jan 2008 20:01:35 +0100
Message-ID: <20080125190135.GA2939@ami.dom.local>
References: <20080124135112.32b5c1c7@deepthought> <20080125082300.GA2257@ff.dom.local> <20080125081315.467fad70@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:39635 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756104AbYAYS7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 13:59:05 -0500
Received: by ug-out-1314.google.com with SMTP id z38so555105ugc.16
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 10:59:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080125081315.467fad70@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 25, 2008 at 08:13:15AM -0800, Stephen Hemminger wrote:
...
> 2. RCU is unnecessary here because of use of RTNL.  I am going to defer
>    on this till after #1. That patch is much less important.

Thanks! (I've started to suspect another advanced RCU trick already...)

Jarek P.
