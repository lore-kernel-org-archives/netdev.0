From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 0/8] net: mvpp2: add TX interrupts support
Date: Fri, 28 Jul 2017 17:03:20 +0200
Message-ID: <20170728170320.4e4bd683@windsurf.lan>
References: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
        <20170726.133533.262039701450895012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk,
        antoine.tenart@free-electrons.com,
        miquel.raynal@free-electrons.com,
        linux-arm-kernel@lists.infradead.org, jason@lakedaemon.net,
        andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        hannah@marvell.com, yehuday@marvell.com, stefanc@marvell.com,
        mw@semihalf.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:52029 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752098AbdG1PDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:03:32 -0400
In-Reply-To: <20170726.133533.262039701450895012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, 26 Jul 2017 13:35:33 -0700 (PDT), David Miller wrote:

> >  - This series depends on the previous series sent by Antoine Ténart
> >    "net: mvpp2: MAC/GoP configuration and optional PHYs". Functionally
> >    speaking there is no real dependency, but we touch in a few areas
> >    the same piece of code, so I based my patch series on top of
> >    Antoine's.
> > 
> >  - Please do not apply the last patch of this series "arm64: dts:
> >    marvell: add TX interrupts for PPv2.2", it will be taken by the ARM
> >    mvebu maintainers.  
> 
> Please don't do things this way.
> 
> Patiently wait for Antione's series to make it into my tree, then
> submit your's.

I'll resubmit when Antoine's series is merged. The idea of submitting
my patches was to allow others to review/test them, not necessarily to
have them merged right away. Perhaps I should have marked them RFC to
make it clear that I don't expect you to merge them right away.

> Also, if we're continually going to elide the DTS file patches, just

It's the dutty of the sub-architecture maintainers to merge the DTS
changes. Merging them through your tree doesn't work really well, as
the changes might very likely conflict with other DTS changes merged by
the sub-architecture maintainer.

But it makes sense to have such DTS changes in the same patch series,
since they are really related. It's very common to have patch series
that contain patches that will be merged by different maintainers.

> don't bother adding them to the series.  That way you don't have to
> give me special instructions, and I don't have the possibility of
> making a mistake and applying it accidently.

... but OK, I won't resend them, so you don't get potentially confused
by such patches.

Thanks!

Thomas Petazzoni
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
