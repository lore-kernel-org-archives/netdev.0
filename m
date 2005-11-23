From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [2.6 patch] do not select NET_CLS
Date: Wed, 23 Nov 2005 06:57:35 +0100
Message-ID: <20051123055735.GC7579@mars.ravnborg.org>
References: <4381F2D2.5000605@trash.net> <20051122.143713.101129339.davem@davemloft.net> <20051122224914.GA17575@mars.ravnborg.org> <20051122.150041.90521592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, bunk@stusta.de, evil@g-house.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zippel@linux-m68k.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030321AbVKWF51@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20051122.150041.90521592.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2005 at 03:00:41PM -0800, David S. Miller wrote:
> From: Sam Ravnborg <sam@ravnborg.org>
> Date: Tue, 22 Nov 2005 23:49:14 +0100
> 
> > On Tue, Nov 22, 2005 at 02:37:13PM -0800, David S. Miller wrote:
> > > 
> > > One thing we can do to prevent human
> > > mistakes, is to make the "make modules" pass do a quick "is vmlinux
> > > uptodate?" check, and if not print out an error message explaining the
> > > situation and aborting the "make modules" attempt.
> > 
> > I do not quite follow you here.
> 
> If the user tries to do a "make modules" without first rebuilding
> their kernel image, then the make will fail if the dependencies
> are not satisfied for the main kernel image and it is thus not
> up to date.

OK - so a simple 'make -q vmlinux' check, except that the way we utilise
make will let it fail at first build command.
That will obscufate things even more in kbuild - but I will give it a
try sometime. It will be easy to cover 95% but to reach 100%
predictability will be though.
- file dependencies is easy
- command line changes is relatively easy
- but the various scripts and user commands will be tricky..

Not on the top of the TODO list though.

	Sam
