From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: A short question about net git tree and patches
Date: Thu, 20 Dec 2007 10:55:10 +0100
Message-ID: <20071220095510.GA2081@uranus.ravnborg.org>
References: <31436f4a0712200120o4e6de008jf999ca1024b47f9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:33589 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197AbXLTJxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 04:53:17 -0500
Content-Disposition: inline
In-Reply-To: <31436f4a0712200120o4e6de008jf999ca1024b47f9d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 20, 2007 at 11:20:26AM +0200, David Shwatrz wrote:
> Hello,
> I have a short question regarding the net git tree and patches:
> I want to write and send patches against the most recent and
> bleeding edge kernel networking code.
> I see in:
> http://kernel.org/pub/scm/linux/kernel/git/davem/?C=M;O=A
> that there are 3 git trees which can be candidates for git-clone and
> making patches against;
> these are:
> netdev-2.6.git, net-2.6.25.git and net-2.6.git.
> 
> It seems to me that net-2.6.git is the most suitable one to work against;
> am I right ?
> what is the difference, in short, between the three repositories?

IIRC the usage is:
netdev-2.6.git   <= old stuff, 4 weeks since last update. Not in use
net-2.6.25.git   <= patches for current kernel release (only fixes)
net-2.6.git      <= patches for next kernel relase and planned to be
                    applied in next merge window

So net-2.6.git is the correct choice for bleeding edge.

	Sam
