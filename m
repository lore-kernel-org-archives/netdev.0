From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 09:28:59 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306090918400.11389@ns.istop.com>
References: <20030608234926.GA9453@netnation.com> <001001c32e19$81bc7ea0$4a00000a@badass>
 <20030609064719.GA20613@netnation.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: CIT/Paul <xerox@foonet.net>, 'Florian Weimer' <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030609064719.GA20613@netnation.com>
List-Id: netdev.vger.kernel.org

On Sun, 8 Jun 2003, Simon Kirby wrote:

> You got a 7200 VXR to do 300kpps?  I would have liked to see that.
> We couldn't get our 7206 VXR routers to do anything more than about 12
> Mbit/second of small packets, which I believe is about 40,000 packets
> per second.  This is with CEF disabled, because it ended up duplicating
> packets and doing some other strange things with CEF enabled.

The trick is finding the good IOS revs.  12.0(7)T and 12.2(11)T have been
good ones for me.  Finding other ISPs running ciscos to exchange tips and
ideas has been much easier than finding folks running linux.  A sure-fire
way to get flamed is to post to NANOG asking what's the best Linux router
setup!

For most ISPs it's better to spend $20K on a 7206VXR/NPE-G1 than to spend
days trying to figure out what kernel + patch set, NIC, and motherboard
combination will squeeze the best performance out of a PC router.  And
once you've done that you still have zebra quirks to worry about...

-Ralph
