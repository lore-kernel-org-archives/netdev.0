From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] Confirm success for each tc -batch command
Date: Wed, 4 Nov 2015 00:35:52 +0100
Message-ID: <20151103233552.GB26876@orbit.nwl.cc>
References: <1446120596-10399-1-git-send-email-phil@nwl.cc>
 <20151103124621.06e37725@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Petr =?utf-8?B?UMOtc2HFmQ==?= <ppisar@redhat.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46650 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbbKCXfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 18:35:55 -0500
Content-Disposition: inline
In-Reply-To: <20151103124621.06e37725@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 03, 2015 at 12:46:21PM -0800, Stephen Hemminger wrote:
> On Thu, 29 Oct 2015 13:09:56 +0100
> Phil Sutter <phil@nwl.cc> wrote:
>=20
> > If `tc -force -batch' is fed by a controlling program from a pipe,
> > it's not possible to recognize when a command has been processes
> > successfully.
> >=20
> > This patch adds an optional `-OK' option to the tc(8) tool, so `tc
> > -force -OK -batch' will print "OK\n" to standard output on each
> > successfully completed tc command.
> >=20
> > Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
>=20
> Why use batch mode if you are feeding it from a pipe?
> This seems like unnecessary feature creep.

This turned up when searching the list of iproute2 patches in RHEL6 for
unpublished changes. It dates back to a feature request from 2012 by a
customer who wanted to know when a command piped into tc was finished
processing. Looking at the ticket again, it appears you rejected this
patch in 2013 already. So I guess everything has been said but "sorry
for the noise"!

Cheers, Phil
