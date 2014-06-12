From: Guillaume Morin <guillaume@morinfr.org>
Subject: Re: Linux 3.4.92 breaks forwarding with netfilter enabled
Date: Thu, 12 Jun 2014 19:25:16 +0200
Message-ID: <20140612172516.GA2556@bender.morinfr.org>
References: <20140610220325.GG1970@breakpoint.cc>
 <53980015.5010409@suse.cz>
 <20140611081053.GH1970@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>, stable@vger.kernel.org,
	ML netdev <netdev@vger.kernel.org>
To: gregkh@linuxfoundation.org, Florian Westphal <fw@strlen.de>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140611081053.GH1970@breakpoint.cc>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11 Jun 10:10, Florian Westphal wrote:
>
> Jiri Slaby <jslaby@suse.cz> wrote:
> > > Gergely, please either revert
> > > 
> > > commit bd91cb56f951a7b0da8c3098ea9cd56854ece66c
> > > Author: Florian Westphal <fw@strlen.de>
> > > net: ipv4: ip_forward: fix inverted local_df test
> > > [ Upstream commit ca6c5d4ad216d5942ae544bbf02503041bd802aa ]
> > > 
> > > Or, alternatively, also apply upstream commit 895162b1101b3ea5db08ca6822ae9672717efec0
> > > Author: Florian Westphal <fw@strlen.de>
> > > Date:   Fri May 2 15:32:16 2014 +0200
> > > netfilter: ipv4: defrag: set local_df flag on defragmented skb
> > > 
> > > on top of your 3.4.92 kernel.
> > > 
> > > (The latter might be a better option since it will also fix the
> > >  long-standing issue where netfilter sends bogus frag-needed message
> > >  under very rare circumstances).
> > 
> > I believe, the same holds for 3.12, right? (I have just applied "defrag:
> > set local_df flag on defragmented skb".)
> 
> Yes, its true for all -stable kernels (except new 3.15).
> 
> Thanks for taking care of this.

Greg, could you apply this one to 3.4,3.10,3.14 as well please?

Or do have concerns about it?

Thanks,

Guillaume.

-- 
Guillaume Morin <guillaume@morinfr.org>
