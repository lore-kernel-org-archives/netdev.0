From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Tue, 03 Jan 2017 23:25:04 +0100
Message-ID: <3780968.pTT7cvIH4p@wuerfel>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de> <3286019.I2UkVCJq41@wuerfel> <1483480459.10534.8.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        devel@driverdev.osuosl.org, Karsten Keil <isdn@linux-pingi.de>,
        linux-doc@vger.kernel.org, netdev@vger.kernel.org,
        Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:63665 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966612AbdACWZo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 17:25:44 -0500
In-Reply-To: <1483480459.10534.8.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, January 3, 2017 10:54:19 PM CET Paul Bolle wrote:
> On Tue, 2017-01-03 at 22:19 +0100, Arnd Bergmann wrote:
> > isdn: move isdnhdlc out of i4l
> > isdn: i4l: move hisax driver to staging
> > isdn: move i4l to staging
> > 
> > I can post those as well, at least I think the first two are helpful
> > for untangling i4l from the rest of ISDN.  I also still think that
> > moving hisax and i4l to staging is reasonable given the state of
> > that code, even if there are a couple of users today.
> 
> There are? And even if there are: is there any reason to expect that moving
> the rest of i4l to staging will result in anything other than a stream of
> checkpatch cleanups?

To clarify: Karsten's concern was about the loss of features that are
present in i4l but not in mISDN. There were active users of those features
last year, so I assumed that there are still a few this year. However,
whether any of those users would ever need to move to a 4.11 kernel or
newer is an entirely different question.

As far as I'm concerned, we are totally fine as long as there exists a
longterm supported kernel that has i4l in drivers/staging. If we move
i4l to staging for v4.11 with the intention of removing it after the
2018 longterm release (i.e. after Deutsche Telekom turns off their
ISDN network), that gives us at least until 2020. I assume there will
be at least one older kernel with a longer end-of-support date.

> How often did a bunch of drivers re-enter the tree after being sent to
> staging?

Greg can probably answer that. I'm sure it's either never or very rare.
The only case of removed code coming back later is arch/h8300, which
was removed in 2013 and replaced with a much nicer implementation
in 2015.

	Arnd
