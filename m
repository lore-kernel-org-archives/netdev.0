From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] Add ethtool set regs support
Date: Sun, 11 Dec 2016 16:22:29 +0100
Message-ID: <20161211152229.GC29761@lunn.ch>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
 <20161207024143.GA655@lunn.ch>
 <CALzJLG8nGU-29VoKDtdaoFuG7zfTvTTu14T91+PMxcJH-GG2bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "John W . Linville" <linville@tuxdriver.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51735 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753232AbcLKPWf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 11 Dec 2016 10:22:35 -0500
Content-Disposition: inline
In-Reply-To: <CALzJLG8nGU-29VoKDtdaoFuG7zfTvTTu14T91+PMxcJH-GG2bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 11, 2016 at 02:18:00PM +0200, Saeed Mahameed wrote:
> On Wed, Dec 7, 2016 at 4:41 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> > On Wed, Dec 07, 2016 at 12:33:08AM +0200, Saeed Mahameed wrote:
> >> Hi Dave,
> >>
> >> This series adds the support for setting device registers from user
> >> space ethtool.
> >
> > Is this not the start of allowing binary only drivers in user space?
> >
> 
> It is not, we want to do same as set_eeprom already do,
> Just set some HW registers, for analysis/debug/tweak/configure HW
> dependent register for the NIC netdev sake.

Mellanox has a good reputation of open drivers. However, this API
sounds like it would be the first step towards user space
drivers. This is an API which can peek and poke registers, so it
probably could be mis-used to put part of a driver in user
space. Hence we should avoid this sort of API to start with.

> where can i find some details about "HW performance counters for CPUs" ?

https://perf.wiki.kernel.org/index.php/Tutorial

	Andrew
