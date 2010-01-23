From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 30/31] CAPI: Remove experimental tag from middleware
 feature
Date: Sat, 23 Jan 2010 12:23:27 +0000
Message-ID: <20100123122327.7d2622f4@lxorguk.ukuu.org.uk>
References: <cover.1264201406.git.jan.kiszka@web.de>
	<9dd553d458def04edc7790f0320ffdf1f8909aa5.1264201408.git.jan.kiszka@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: Jan Kiszka <jan.kiszka@web.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755050Ab0AWMVa@vger.kernel.org>
In-Reply-To: <9dd553d458def04edc7790f0320ffdf1f8909aa5.1264201408.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 10 Jan 2010 14:12:41 +0100
Jan Kiszka <jan.kiszka@web.de> wrote:

> Despite all its bugs, the middleware support of our CAPI stack was
> already in use for many, many moons. And after going through its code,
> fixing all issues I found, I feel it deserves to officially become a
> non-experimental feature.

Slightly NAK this - I'm really glad to see the work getting done, but
until it uses krefs properly for the tty references I'd say it is
experimental still.

I'd like to help you sort out the tty krefs stuff, using tty_port and so
on and get that wart fixed too.

Alan
