From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC] back on nf_tables (plus compatibility layer)
Date: Wed, 31 Oct 2012 16:42:16 +0100
Message-ID: <20121031154216.GB9558@1984>
References: <20121025170632.GA4890@1984>
 <alpine.LNX.2.01.1210252352420.13437@nerf07.vanv.qr>
 <20121026110419.GA16629@1984>
 <alpine.LNX.2.01.1210311449570.29232@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1210311449570.29232@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31, 2012 at 02:50:27PM +0100, Jan Engelhardt wrote:
> 
> On Friday 2012-10-26 13:04, Pablo Neira Ayuso wrote:
> >> 
> >> Meanwhile, I am on xtables2 that actually reproduces the set of
> >> _really important_ features that currently are in the setsockopt
> >> iptables, like atomic table replace and atomic dump.
> >> 
> >> I have updated to the newest tree, and the first set is
> >> available in the git repository at:
> >>   git://git.inai.de/linux xt2-20121025
> >
> >If you think this feature is important, checkout nf_tables and think
> >how to integrate this prototype code that provides atomic table
> >replacement to it.
> 
> I'd rather tinker with xt2.

You're are free spend your time on your pet project, but I warn you:
it will *extremely hard* to justify its inclusion into mainline.

As said, I don't think it makes sense to add two firewall
engines/interfaces for the same thing. And the compatibility layer
provides an utility with similar syntax and semantics to iptables.
