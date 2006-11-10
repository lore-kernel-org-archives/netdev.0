From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [NET] Update documentation of skb_linearize
Date: Sat, 11 Nov 2006 00:34:50 +0100
Message-ID: <20061110233450.GD9453@electric-eye.fr.zoreil.com>
References: <20061110213043.GB9453@electric-eye.fr.zoreil.com> <20061110133555.7400e555@freekitty> <20061110220355.GC9453@electric-eye.fr.zoreil.com> <20061110.145346.125893910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, dale@farnsworth.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:23271 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1946721AbWKJXgs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 18:36:48 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061110.145346.125893910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> :
[...]
> Yes it is.
> 
> If the non-linear SKB has data in pages, we copy that data from the
> pages into the new linear skb->data area and release the paged data.


Right. The documentation talks about the skb _data_ so there is no
reason to imagine that the function could freed the skb on failure.

I'll leave Stephen reformulate the documentation if he feels the need to.

-- 
Ueimor
