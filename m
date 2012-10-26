From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC] back on nf_tables (plus compatibility layer)
Date: Fri, 26 Oct 2012 13:04:19 +0200
Message-ID: <20121026110419.GA16629@1984>
References: <20121025170632.GA4890@1984>
 <alpine.LNX.2.01.1210252352420.13437@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1210252352420.13437@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 26, 2012 at 12:02:56AM +0200, Jan Engelhardt wrote:
> On Thursday 2012-10-25 19:06, Pablo Neira Ayuso wrote:
> 
> >Hi,
> >
> >I've been working for a while to recover nf_tables kernel patches and
> >to implement a compatibility layer so it can be used with existing
> >x_tables target/match extensions. [...]
> >2) Provide a fast path to merge this into mainstream. We'll have both
> >   iptables and nftables interfaces during some time in the Linux kernel,
> >   then remove iptables infrastructure at some point. iptables scripts
> >   would not break as we'll have the iptables emulation over nftables.
> >[...]
> >One final thing: nftables does not support atomic table commit. The
> >point here is if we really need this for the emulation utility or we
> >can live without that. Implementing atomic table replacement in
> >nftables is not trivial. I have hard time to find this commit table
> >feature useful.
> 
> Meanwhile, I am on xtables2 that actually reproduces the set of
> _really important_ features that currently are in the setsockopt
> iptables, like atomic table replace and atomic dump.
> 
> I have updated to the newest tree, and the first set is
> available in the git repository at:
>   git://git.inai.de/linux xt2-20121025

If you think this feature is important, checkout nf_tables and think
how to integrate this prototype code that provides atomic table
replacement to it.
