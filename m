From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: iproute2: bash completion function for tc
Date: Thu, 28 Apr 2016 09:53:50 -0700
Message-ID: <20160428165349.GB81443@ast-mbp.thefacebook.com>
References: <571F1891.1030004@6wind.com>
 <20160428031923.GA76700@ast-mbp.thefacebook.com>
 <20160427221346.32ec7bcb@samsung9>
 <5721FEE1.7080807@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Vincent Jardin <vincent.jardin@6wind.com>,
	netdev@vger.kernel.org
To: Quentin Monnet <quentin.monnet@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33012 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbcD1Qxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 12:53:55 -0400
Received: by mail-pf0-f181.google.com with SMTP id 206so36033406pfu.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 09:53:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5721FEE1.7080807@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 02:15:29PM +0200, Quentin Monnet wrote:
> Hi Alexei, Stephen,
> 
> 2016-04-27 (22:13 UTC-0700) ~ Stephen Hemminger:
> > On Wed, 27 Apr 2016 20:19:26 -0700
> > Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> > 
> >> On Tue, Apr 26, 2016 at 09:28:17AM +0200, Quentin Monnet wrote:
> >>> Hi Jamal, Stephen,
> >>>
> >>> I searched for a function providing auto-completion for `tc` utility in
> >>> bash, but I found none. So I have created one, and I would like share it
> >>> with the community. It is available here:
> >>> https://github.com/6WIND/tc_bash-completion/blob/master/tc
> >>> I would like to make it easily available to tc users, so here is a
> >>> twofold request:
> >>>
> >>> * I do not know where to submit the code. Should I submit here on netdev
> >>> for inclusion in iproute2 package, or rather to the bash-completion
> >>> repository on GitHub? I feel like it would receive better feedback and
> >>> updates if pushed to iproute2. Could you please provide some advice here?
> >>> * The completion for `tc` seems to work well; I have tested it with many
> >>> commands, but I am no tc expert, and there are probably some cases where
> >>> the completion fails to propose the correct choices. I would be really
> >>> interested in any feedback/bug reports that you, or anyone on this list
> >>> who uses tc, could provide.
> >>
> >> that looks very interesting.
> >> I think making it a part of iproute2 is a good thing.
> >> How about installing it into /etc/iproute2/ ?
> >> Stephen, any comments?
> >>
> > 
> > I am ok with keeping it in the repository.
> > But it would need to be installed in the standard bash directory,
> > is that distro dependent?
> > 
> 
> As far as I know the bash-completion directory is not distro dependent,
> but it moved at some point (2011) from /etc/bash_completion.d/ to
> /usr/share/bash-completion/completions/. While backward compatibility is
> provided with the former location, it is now recommended to use the latter.
> 
> So one idea could be to check (in iproute2 Makefile) for existence of
> /usr/share/bash-completion/completions/ directory, and if not found to
> fall back to /etc/bash_completion.d/. If none is found, use
> /usr/share/bash-completion/completions/. Does this seem correct?

make sense to me.
For some reason there is also /etc/bash-completion.d/ (note - vs _)
and git installs there (which seems to be a bug), but your proposal is good as-is.
