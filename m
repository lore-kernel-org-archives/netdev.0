From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 01/14] netfilter: bridge: really save
 frag_max_size between PRE and POST_ROUTING
Date: Thu, 2 Apr 2015 10:54:30 +0200
Message-ID: <20150402085430.GA11570@salvia>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
 <1427920600-20366-2-git-send-email-fw@strlen.de>
 <20150402085322.GA10375@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44242 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbbDBIuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 04:50:24 -0400
Content-Disposition: inline
In-Reply-To: <20150402085322.GA10375@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2015 at 10:53:22AM +0200, Pablo Neira Ayuso wrote:
> On Wed, Apr 01, 2015 at 10:36:27PM +0200, Florian Westphal wrote:
> > We also need to save/store in forward, else br_parse_ip_options call
> > will zero frag_max_size as well.
> 
> I have only applied this fix to nf-next. Thanks.

BTW, you can resubmit patches in case they are independent of the
ip_fragment() change in first place. Thanks.
