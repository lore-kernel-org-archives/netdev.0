From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: A short question about net git tree and patches
Date: Thu, 20 Dec 2007 12:49:50 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712201245160.31652@kivilampi-30.cs.helsinki.fi>
References: <31436f4a0712200120o4e6de008jf999ca1024b47f9d@mail.gmail.com>
 <20071220095510.GA2081@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>, David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53172 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510AbXLTKty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 05:49:54 -0500
In-Reply-To: <20071220095510.GA2081@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2007, Sam Ravnborg wrote:

> On Thu, Dec 20, 2007 at 11:20:26AM +0200, David Shwatrz wrote:
> > Hello,
> > I have a short question regarding the net git tree and patches:
> > I want to write and send patches against the most recent and
> > bleeding edge kernel networking code.
> > I see in:
> > http://kernel.org/pub/scm/linux/kernel/git/davem/?C=M;O=A
> > that there are 3 git trees which can be candidates for git-clone and
> > making patches against;
> > these are:
> > netdev-2.6.git, net-2.6.25.git and net-2.6.git.
> > 
> > It seems to me that net-2.6.git is the most suitable one to work against;
> > am I right ?
> > what is the difference, in short, between the three repositories?
> 
> IIRC the usage is:
> netdev-2.6.git   <= old stuff, 4 weeks since last update. Not in use
> net-2.6.25.git   <= patches for current kernel release (only fixes)

Nope, we don't even have 2.6.24 yet. :-)

> net-2.6.git      <= patches for next kernel relase and planned to be
>                     applied in next merge window
>
> So net-2.6.git is the correct choice for bleeding edge.

net-2.6 is for fixes only, net-2.6.25 will become net-2.6 once 2.6.24
gets released, eventually net-2.6.26 gets opened (not necessarily at the 
same time as the merge window is closed but a bit later) and the cycle 
repeats with similar transitions when 2.6.25 gets released.

The netdev trees are for network drivers and are usually managed by
Jeff Garzik but there were recently some arrangement between Dave and 
Jeff due to vacations so that also netdev was managed by Dave.

-- 
 i.
