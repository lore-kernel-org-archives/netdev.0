From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Sun, 27 Nov 2016 23:42:59 +0100
Message-ID: <e5d45b55-a4c1-3b5e-0bdc-a5e340b072d0@suse.de>
References: <1480280279-9552-1-git-send-email-afaerber@suse.de>
 <1480280279-9552-2-git-send-email-afaerber@suse.de>
 <20161127212709.GD13318@lunn.ch>
 <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de>
 <20161127220846.GH13318@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        Bed??icha Ko??atu <bedrich.kosata@nic.cz>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58065 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751532AbcK0WnC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 17:43:02 -0500
In-Reply-To: <20161127220846.GH13318@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

Am 27.11.2016 um 23:08 schrieb Andrew Lunn:
>>> This driver already supports nearly 30 different Marvell switch
>>> models. Please document why the marvell,mv88e6176 is special and why
>>> it needs its own compatible string when the others don't.
>>
>> I don't understand.
> 
> Think about what i said. Why does the 6176 need its own compatible
> string, when the two 6352s and the 6165 on the zii-devel-b don't have
> one? And the DIR 665 has a 6171, which does not have a compatible
> string of its own. The clearfog actually has a 6176, and it seems to
> work fine without a compatible string.
> 
>> You as driver author should know that the .data pointer is vital to your
>> driver
> 
> Exactly, so if i ask why is it needed, maybe you should stop and think
> for a while.
> 
>> you even recently accepted another model that conflicted with
>> my patch.
> 
> And think about that also, and you will find the 6390 family, who's
> first device is 6190, is not compatible with the 6085, and so needs a
> different compatible string.

Try to see it from my perspective: I see that some vf610 device I don't
have (found via `git grep marvell,mv88e6` or so) uses
"marvell,mv88e6085". I then assume it has that device on board. How
would I know it doesn't? Same for the other boards you mention.

Unfortunately some of your replies are slightly cryptic. Had you simply
replied 'please just use "marvell,mv88e6085" instead', it would've been
much more clear what you want. (Same for extending the subject instead
of just pointing to some FAQ.)

So are you okay with patch 1/2 documenting the compatible? Then we could
drop 2/2 and use "marvell,mv88e6176", "marvell,mv88e6085" instead of
just the latter. Or would you rather drop both and keep the actual chip
a comment?

Regards,
Andreas

-- 
SUSE Linux GmbH, Maxfeldstr. 5, 90409 Nürnberg, Germany
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
