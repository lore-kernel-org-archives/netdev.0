From: Florian Westphal <fw@strlen.de>
Subject: Re: Linux 3.4.92 breaks forwarding with netfilter enabled
Date: Wed, 11 Jun 2014 10:10:53 +0200
Message-ID: <20140611081053.GH1970@breakpoint.cc>
References: <20140610220325.GG1970@breakpoint.cc>
 <53980015.5010409@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, stable@vger.kernel.org,
	ML netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51581 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752718AbaFKIK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 04:10:56 -0400
Content-Disposition: inline
In-Reply-To: <53980015.5010409@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby <jslaby@suse.cz> wrote:
> > Gergely, please either revert
> > 
> > commit bd91cb56f951a7b0da8c3098ea9cd56854ece66c
> > Author: Florian Westphal <fw@strlen.de>
> > net: ipv4: ip_forward: fix inverted local_df test
> > [ Upstream commit ca6c5d4ad216d5942ae544bbf02503041bd802aa ]
> > 
> > Or, alternatively, also apply upstream commit 895162b1101b3ea5db08ca6822ae9672717efec0
> > Author: Florian Westphal <fw@strlen.de>
> > Date:   Fri May 2 15:32:16 2014 +0200
> > netfilter: ipv4: defrag: set local_df flag on defragmented skb
> > 
> > on top of your 3.4.92 kernel.
> > 
> > (The latter might be a better option since it will also fix the
> >  long-standing issue where netfilter sends bogus frag-needed message
> >  under very rare circumstances).
> 
> I believe, the same holds for 3.12, right? (I have just applied "defrag:
> set local_df flag on defragmented skb".)

Yes, its true for all -stable kernels (except new 3.15).

Thanks for taking care of this.
