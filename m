From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCHv2] netfilter: Remove skb_is_nonlinear check from
	nf_conntrack_sip
Date: Fri, 14 May 2010 13:56:55 -0600
Message-ID: <20100514195655.GK15969@obsidianresearch.com>
References: <20100514180138.GF15969@obsidianresearch.com> <4BED92AF.50704@trash.net> <20100514182601.GJ15969@obsidianresearch.com> <4BED99A3.2050404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BED99A3.2050404@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 14, 2010 at 08:42:43PM +0200, Patrick McHardy wrote:

> > Should this be NF_DROP? As I understand it skb_linearize only failes
> > if it runs out of memory, which probably means dropping is OK. But
> > passing a packet that might need rewriting could be harmful..
> 
> We so far also didn't rewrite the packet. But agreed, its
> a corner case and dropping it is the safer choice.

I was just thinking that, say, a request goes out, gets rewritten but
the reply comes back and does not get rewritten = bad. Better to drop.

Looks OK to me..

Jason
