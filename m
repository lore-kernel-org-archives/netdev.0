From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: [PATCH] dst numa: Avoid dst counter cacheline bouncing
Date: Fri, 24 Jun 2005 12:59:26 +0530
Message-ID: <20050624072926.GA4804@in.ibm.com>
References: <Pine.LNX.4.62.0506231953260.28244@graphe.net> <Pine.LNX.4.62.0506232005030.28244@graphe.net> <20050624045854.GA6465@in.ibm.com> <Pine.LNX.4.62.0506232204320.30382@graphe.net>
Reply-To: dipankar@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, shai@scalex86.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263192AbVFXHcX@vger.kernel.org>
To: Christoph Lameter <christoph@lameter.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0506232204320.30382@graphe.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2005 at 10:05:09PM -0700, Christoph Lameter wrote:
> On Fri, 24 Jun 2005, Dipankar Sarma wrote:
> 
> > Do we really need to do a distributed reference counter implementation
> > inside dst cache code ? If you are willing to wait for a while,
> > we should have modified Rusty's bigref implementation on top of the 
> > interleaving dynamic per-cpu allocator. We can look at distributed 
> > reference counter for dst refcount then and see how that can be 
> > worked out.
> 
> Is that code available somewhere?

Various places in lkml discussions. Search for discussions on dynamic
per-cpu allocator. Currently Bharata is adding
cpu hotplug awareness in it, but the basic patches work.

BTW, I am not saying that bigref has what you need. What I am trying
to say is that you should see if something like bigref can
be tweaked to use in your case before implementing a new type of
ref counting wholly in dst code.

Thanks
Dipankar
