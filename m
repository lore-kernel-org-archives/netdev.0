From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
Date: Fri, 4 May 2007 14:09:40 -0400
Message-ID: <170fa0d20705041109j1d130456p4b7cef3633f8edb4@mail.gmail.com>
References: <20070504102651.923946304@chello.nl>
	 <1178292179.7997.12.camel@imap.mvista.com>
	 <1178293081.24217.46.camel@twins>
	 <1178294379.7997.26.camel@imap.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Peter Zijlstra" <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Thomas Graf" <tgraf@suug.ch>,
	"David Miller" <davem@davemloft.net>,
	"James Bottomley" <James.Bottomley@steeleye.com>,
	"Mike Christie" <michaelc@cs.wisc.edu>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Daniel Phillips" <phillips@google.com>
To: "Daniel Walker" <dwalker@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.235]:59412 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031480AbXEDSJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 14:09:42 -0400
Received: by hu-out-0506.google.com with SMTP id 36so1244953hui
        for <netdev@vger.kernel.org>; Fri, 04 May 2007 11:09:41 -0700 (PDT)
In-Reply-To: <1178294379.7997.26.camel@imap.mvista.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/4/07, Daniel Walker <dwalker@mvista.com> wrote:
> On Fri, 2007-05-04 at 17:38 +0200, Peter Zijlstra wrote:
> > >
> > > This is kind of a lot of patches all at once .. Have you release any of
> > > these patch sets prior to this release ?
> >
> > Like the -v12 suggests, this is the 12th posting of this patch set.
> > Some is the same, some has changed.
>
> I can find one prior release with this subject (-v11) , what was the
> subject prior to that release? It's not a hard rule, but usually >15
> patches is too many (check Documentation/SubmittingPatches under
> references).. You might want to consider submitting a URL instead.

Previous subjects were like:
[PATCH 00/20] vm deadlock avoidance for NFS, NBD and iSCSI (take 7)

A URL doesn't allow for true discussion about a particular patch
unless the reviewer takes the initiative to create a new thread to
discuss the Nth patch it a patchset; whereby taking on the burden of a
structured subject and so on.  It would get out of control on a large
patchset that actually got a lot of simultaneous feedback... reviewers
don't have a forum to talk about each individual change without
stepping on each others' toes.

> I think it's a benefit to release less since a developer (like myself)
> might know very little about "Swap over Networked storage", but if you
> submit 10 patches that developer might still review it, 40 patches they
> likely wouldn't review it.

The _suggestions_ in Documentation/SubmittingPatches are nice and all
but the quantity of patches shouldn't _really_ matter.

Documentation/SubmittingPatches actually doesn't cover how to post a
large change because it first states:
"Separate _logical changes_ into a single patch file."
then:
"If you cannot condense your patch set into a smaller set of patches,
then only post say 15 or so at a time and wait for review and integration."

These suggestions conflict in the case of a large patchset: the second
can't be met if you honor the first (more important suggestion IMHO).
Unless you leave something out... and I can't see the value in leaving
out the auxiliary consumers of the core changes.

Reviewing 10 patches that are quite large/overloaded is actually
harder than 40 broken-out/well-documented patches.  But maybe others
disagree.

*shrug*
