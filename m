From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: Line layout whitespace fixes
Date: Fri, 2 Oct 2015 13:19:02 +0200
Message-ID: <20151002111902.GA29902@salvia>
References: <1443089406-8996-1-git-send-email-ipm@chirality.org.uk>
 <20150930221707.GA14994@salvia>
 <560DC543.3060809@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <560DC543.3060809@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 02, 2015 at 12:44:03AM +0100, Ian Morris wrote:
> 
> On 30/09/15 23:17, Pablo Neira Ayuso wrote:
> >On Thu, Sep 24, 2015 at 11:10:06AM +0100, Ian Morris wrote:
> >>Fixes various whitespace issues detected by checkpatch (e.g. adding spaces between operations, replacing spaces with tabs, etc)
> >>
> >>No changes detected by objdiff.
> >These large cleanup patch causes problems for -stable maintainers,
> >since they have more conflicts when backporting stuff.
> >
> >I'd rather keep this back.
> >
> Please help me understand: until when do you propose such changes be
> deferred? Or are you suggesting we should apply changes more incrementally
> somehow?

Regarding your suggestion to apply changes more incrementally, I think
that's a good idea since that will help us evaluate if there are
better things we can do to improve that code.

So please go send small batches with incremental way that we can
review.  Depending on the change, some of them may trigger the rework
of existing code, others probably will just get in as is.

Thanks.
