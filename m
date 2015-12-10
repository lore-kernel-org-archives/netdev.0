From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 0/3] ser_gigaset fixes
Date: Thu, 10 Dec 2015 12:31:09 +0100
Message-ID: <1449747069.16068.27.camel@tiscali.nl>
References: <cover.1449570042.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1449570042.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tilman,

On di, 2015-12-08 at 12:00 +0100, Tilman Schmidt wrote:
> this series is the result of our discussion on the "freeing an
> active object" bug. I split my proposed patch into two patches
> for the separate topics of moving the ser_cardstate kfree() and
> dropping the useless kfree()s, and also included an unrelated
> patch (1/3) that had fallen through the cracks in my last series.
> 
> Patch 2/3 should go into stable releases all the way back to 2.6.32.
> It applies cleanly to release 3.*/4.* with at most offset 1.
> For release 2.6.32 there is a trivial merge conflict with a removed
> comment line.

1/3 ran into objections and, I think, Alan Cox is working on an
alternative for it. Would you mind resending 2/3 and 3/3 as a two
patches series? Feel free to add
    Acked-by: Paul Bolle <pebolle@tiscali.nl>

to both.

(The previous gigaset series, which you sent in July this year, was
picked up from netdev directly by David Miller. Unless people actually
prefer these patches to also be signed-off by me, I'm perfectly fine
with that.)

Thanks,


Paul Bolle
