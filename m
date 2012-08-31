From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 00/18] netfilter: IPv6 NAT
Date: Fri, 31 Aug 2012 11:29:59 +0200
Message-ID: <20120831092959.GA7524@1984>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47995 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631Ab2HaJaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 05:30:04 -0400
Content-Disposition: inline
In-Reply-To: <1345434006-16549-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 20, 2012 at 05:39:48AM +0200, Patrick McHardy wrote:
> Following is the latest IPv6 NAT patchset, based on -rc2.
> 
> Changes since the last posting include:
> 
> - removal of fixes already merged into nf-2.6, not included upstream
>   yet though, IPv6 SIP will not work
> 
> - missing module alias for ip6t_DNAT/ip6t_SNAT added to xt_nat
> 
> - compilation fix for ip6t_MASQUERADE without ipt_MASQUERADE enabled
> 
> - proper handling of untracked packets in IPv6 fragmentation improvements
> 
> - byteorder fixes in IPv6 fragment handling
> 
> - conversion to use a mutex for NAT L3/L4 protocol registration
> 
> - missing memory barrier before publishing L4 protocol array
> 
> - proper cleanup of NATed connections after NAT L3/L4 protocol unregistration
> 
> - proper locking (RTNL) for walking network namespaces in NAT cleanup
> 
> - only free NAT L4 protocol array at shutdown instead of during L3 protocol
>   unregistation, otherwise non built-in protocols are missing after L3
>   protocol reload
> 
> - endianess annotation fixes
> 
> - missing netlink policy for IPv6 NAT attributes
> 
> I'll also push these patches to github, but it is currently acting up,
> once it works again they'll be available at
> 
> git://github.com/kaber/nf-nat-ipv6.git master

Pulled. Thanks a lot Patrick.

And I fixed the log description that Jesper mentioned. You'll have to
rebase though, sorry.
