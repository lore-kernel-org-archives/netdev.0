From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC] net/fs_enet: send a reset request to the PHY on init
Date: Fri, 4 Sep 2009 09:45:54 -0600
Message-ID: <fa686aa40909040845v7410446eqe16a537c398252b7@mail.gmail.com>
References: <20090902110410.GC15401@www.tglx.de> <fa686aa40909030948h4acf6d3x1c318baa2fdefe1f@mail.gmail.com>
	<4AA1347A.5060702@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Wolfgang Denk <wd@denx.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f182.google.com ([209.85.210.182]:40891 "EHLO
	mail-yx0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932404AbZIDPqX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 11:46:23 -0400
Received: by yxe12 with SMTP id 12so2936004yxe.1
        for <netdev@vger.kernel.org>; Fri, 04 Sep 2009 08:46:25 -0700 (PDT)
In-Reply-To: <4AA1347A.5060702@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 4, 2009 at 9:38 AM, Sebastian Andrzej
Siewior<bigeasy@linutronix.de> wrote:
> Grant Likely wrote:
> =A0> What version of the kernel are you using? =A0The line numbers do=
n't
>>
>> match up with kernel mainline, so I wonder if this is before or afte=
r
>> the OF MDIO rework changes.
>
> It is the kernel which was shipped in ads5121's bsp which is 2.6.24.

Okay, I can safely ignore this then.  Wolfgang may be interested
though.  He's been doing some work to get 5121 support mainlined.

> I have no network support in boot loader so I can't do it there. Doin=
g it at
> phy-probe time sounds reasonable.
> So all other boards are doing this kind of reset in u-boot?

In general I take the approach that as much as possible firmware
should have devices in a sane state before booting the kernel just to
avoid doing board specific fixup stuff in the kernel tree.  But this
isn't law, just more of a rule of thumb that I go by.  2nd resort is
to create a board specific platform code file and put it there
(arch/powerpc/platforms/*).

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
