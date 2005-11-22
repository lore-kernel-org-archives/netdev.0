From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] do not select NET_CLS
Date: Tue, 22 Nov 2005 15:00:41 -0800 (PST)
Message-ID: <20051122.150041.90521592.davem@davemloft.net>
References: <4381F2D2.5000605@trash.net>
	<20051122.143713.101129339.davem@davemloft.net>
	<20051122224914.GA17575@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, bunk@stusta.de, evil@g-house.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zippel@linux-m68k.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030225AbVKVXAX@vger.kernel.org>
To: sam@ravnborg.org
In-Reply-To: <20051122224914.GA17575@mars.ravnborg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 22 Nov 2005 23:49:14 +0100

> On Tue, Nov 22, 2005 at 02:37:13PM -0800, David S. Miller wrote:
> > 
> > One thing we can do to prevent human
> > mistakes, is to make the "make modules" pass do a quick "is vmlinux
> > uptodate?" check, and if not print out an error message explaining the
> > situation and aborting the "make modules" attempt.
> 
> I do not quite follow you here.

If the user tries to do a "make modules" without first rebuilding
their kernel image, then the make will fail if the dependencies
are not satisfied for the main kernel image and it is thus not
up to date.
