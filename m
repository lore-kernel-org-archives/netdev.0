From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 08/23] netfilter: nft_ct: load both IPv4 and IPv6
 conntrack modules for NFPROTO_INET
Date: Fri, 10 Jan 2014 19:59:40 +0000
Message-ID: <20140110195940.GA24838@macbook.localnet>
References: <1389314142-17969-9-git-send-email-pablo@netfilter.org>
 <52D05AC6.20000@cogentembedded.com>
 <20140110194235.GA9253@macbook.localnet>
 <20140110.144813.659408334812475090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sergei.shtylyov@cogentembedded.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61913 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaAJT7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:59:46 -0500
Content-Disposition: inline
In-Reply-To: <20140110.144813.659408334812475090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 02:48:13PM -0500, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 10 Jan 2014 19:42:36 +0000
> 
> > I can see you're looking out for the important stuff. I consistently
> > used this style in nftables so I'm not going to change it here.
> 
> Patrick, please follow the coding style conventions of the kernel,
> these issues are important for long term sanity of the kernel tree.
> 
> It helps people who are looking at the netfilter code who perhaps
> do not do so usually.  Do you really want to use a different style
> and therefore make your code harder to read for them?  Really?
> 
> Your code being consistent with your code only is less important than
> all of the networking looking the same.
> 
> Thank you.

I agree to this, in fact style divergences really bother me since they
divert my attention :) I considered consistency more important for minor
stuff like this, but I really don't mind to add extra braces.
But I guess we both agree that its not worth sending patches just to
change this but just fix this up next time that line is touched.
