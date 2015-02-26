From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Wed, 25 Feb 2015 23:21:58 -0500
Message-ID: <20150226042158.GF1332@gospo.home.greyhouse.net>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
 <20150224223039.GC1332@gospo.home.greyhouse.net>
 <CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
 <54ED017E.6000902@gmail.com>
 <20150225001534.GB15633@lunn.ch>
 <54ED19AB.7020003@gmail.com>
 <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
 <20150225140356.GB17992@lunn.ch>
 <20150225154607.GD1332@gospo.home.greyhouse.net>
 <CAE4R7bB0ZqjA+2C7EL7fe0o1fvzoNofMmZsbD6FK4_ZYKXdrhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, Rafa?? Mi??ecki <zajec5@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:61898 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbbBZEWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 23:22:03 -0500
Received: by mail-qa0-f53.google.com with SMTP id k15so6120619qaq.12
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 20:22:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAE4R7bB0ZqjA+2C7EL7fe0o1fvzoNofMmZsbD6FK4_ZYKXdrhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2015 at 04:53:24PM -0800, Scott Feldman wrote:
> On Wed, Feb 25, 2015 at 7:46 AM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > On Wed, Feb 25, 2015 at 03:03:56PM +0100, Andrew Lunn wrote:
> > [...]
> >>
> >> What we don't want is X chip families and Y different ways to
> >> configure the features. Ideal we want X chip families, and one way to
> >> configure them all.
> >
> > This statement is really my primary concern.  There is lots of interest
> > around hardware offload at this point and it seems like there is a risk
> > that a lack of consistency can create problems.
> >
> > I think these patches are great as they allow for the programming of the
> > offload hardware (and it has been pointed out that this drastically
> > increases performance), but one concern I have with this patch (related
> > to this) is that I'm not sure there is a major need to create netdevs
> > automatically if there is not the ability to rx/tx actual frames on
> > these interfaces.
> 
> Even when not used for rx/tx to CPU, it seems the netdevs are still
> useful as an anchor to build higher-level constructs such as bridge or
> bond, and to hang stuff like netdev stats or ethtool-ish things.
> 

I agree that they are useful, but now we are really dealing with a
netdev that is slightly lower functionality than we expect from a netdev
right now.
