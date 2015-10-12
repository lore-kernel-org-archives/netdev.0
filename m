From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 3/3] ipv6: Pass struct net into
 nf_ct_frag6_gather
Date: Mon, 12 Oct 2015 22:12:18 +0200
Message-ID: <20151012201218.GB12460@salvia>
References: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
 <1444416295-31683-3-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58089 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbbJLUFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2015 16:05:19 -0400
Content-Disposition: inline
In-Reply-To: <1444416295-31683-3-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2015 at 01:44:55PM -0500, Eric W. Biederman wrote:
> The function nf_ct_frag6_gather is called on both the input and the
> output paths of the networking stack.  In particular ipv6_defrag which
> calls nf_ct_frag6_gather is called from both the the PRE_ROUTING chain
> on input and the LOCAL_OUT chain on output.
> 
> The addition of a net parameter makes it explicit which network
> namespace the packets are being reassembled in, and removes the need
> for nf_ct_frag6_gather to guess.

For the netfilter chunk:

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
