From: Xavier Bestel <xavier.bestel@free.fr>
Subject: Re: bonding: cannot remove certain named devices
Date: Thu, 17 Aug 2006 09:29:43 +0200
Message-ID: <1155799783.7566.5.camel@capoeira>
References: <6KfTz-OX-11@gated-at.bofh.it> <6KfTA-OX-15@gated-at.bofh.it>
	 <E1GD8rX-0001cA-CV@be1.lrz> <20060815.171002.104028951.davem@davemloft.net>
	 <44E2BC9C.1000101@debian.org>
	 <20060816133811.GA26471@nostromo.devel.redhat.com>
	 <Pine.LNX.4.58.0608161636250.2044@be1.lrz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bill Nottingham <notting@redhat.com>,
	"Giacomo A. Catenazzi" <cate@debian.org>,
	David Miller <davem@davemloft.net>, 7eggert@elstempel.de,
	shemminger@osdl.org, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.orange.fr ([193.252.22.28]:64533 "EHLO
	smtp-msa-out03.orange.fr") by vger.kernel.org with ESMTP
	id S932187AbWHQHaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 03:30:22 -0400
To: Bodo Eggert <7eggert@gmx.de>
In-Reply-To: <Pine.LNX.4.58.0608161636250.2044@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-16 at 17:11, Bodo Eggert wrote:
> On Wed, 16 Aug 2006, Bill Nottingham wrote:
> > Giacomo A. Catenazzi (cate@debian.org) said: 
> 
> > > > Are you willing to work to add the special case code necessary to
> > > > handle whitespace characters in the device name over all of the kernel
> > > > code and also all of the userland tools too?
> > > 
> > > But if you don't handle spaces in userspace, you handle *, ?, [, ], $,
> > > ", ', \  in userspace? Should kernel disable also these (insane device
> > > chars) chars?
> > 
> > Don't forget unicode characters!
> 
> And long names or control characters.
> 
> > Seriously, while it might be insane to use some of these, I'm wondering
> > if trying to filter names is more work than fixing the tools.
> 
> I think it's sane to avoid control characters and unicode/iso*, since they
> can interfere with log output or analysis. I only thought about the kernel
> itself and the corresponding userspace tools, which should handle any
> character sequence just fine or could be easily fixed.

Why not simply retricting chars to isalnum() ones ?

	Xav

