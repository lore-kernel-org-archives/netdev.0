From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [2.6 patch] do not select NET_CLS
Date: Tue, 22 Nov 2005 23:49:14 +0100
Message-ID: <20051122224914.GA17575@mars.ravnborg.org>
References: <20051116235813.GS5735@stusta.de> <20051121155955.GW16060@stusta.de> <4381F2D2.5000605@trash.net> <20051122.143713.101129339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, bunk@stusta.de, evil@g-house.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zippel@linux-m68k.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030215AbVKVWtI@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20051122.143713.101129339.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2005 at 02:37:13PM -0800, David S. Miller wrote:
> 
> One thing we can do to prevent human
> mistakes, is to make the "make modules" pass do a quick "is vmlinux
> uptodate?" check, and if not print out an error message explaining the
> situation and aborting the "make modules" attempt.


I do not quite follow you here.

For a while I have considered implementing something that told why a
given file was compiled - like:

 CC     net/ipv4/ip_gre.o   due to net/dsfield.h, net/xfrm.h
 CC     net/ipv4/raw.c   due to include/config/ip/mroute.h

The latter is a config option that I do not see a possibility to change
back to a config option syntax (at least not without doing some effort).

My thinking was that 'make V=2' would give above printout.

But what you request is something that keep the dense printout without
building the kernel - right?

Any suggestion for an intuitive syntax to enable that?
'make -n V=2' will not do it.

	Sam
