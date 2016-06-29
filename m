From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [RFC 3/7] net: ethernet: bgmac: move BCMA MDIO Phy code into a
 separate file
Date: Wed, 29 Jun 2016 16:08:20 -0400
Message-ID: <CAC3K-4p9z5pmxmga_ssZ_VA6RNFD5dTTCvms=KJMWvZDVxtNqw@mail.gmail.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-4-git-send-email-jon.mason@broadcom.com>
 <20160629141324.GA24194@lunn.ch> <577414F0.3060609@gmail.com> <20160629184618.GC7480@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	davem@davemloft.net, Hauke Mehrtens <hauke@hauke-m.de>,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:36939 "EHLO
	mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbcF2UIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 16:08:36 -0400
Received: by mail-it0-f50.google.com with SMTP id f6so50664360ith.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 13:08:21 -0700 (PDT)
In-Reply-To: <20160629184618.GC7480@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016 at 2:46 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Jun 29, 2016 at 11:35:28AM -0700, Florian Fainelli wrote:
>> On 06/29/2016 07:13 AM, Andrew Lunn wrote:
>> > Hi Jon
>> >
>> > I know you are just refactoring code, but at some point it would be
>> > good to take a closer look at this MDIO bus driver.
>
>> And, to re-iterate all of your points are valid, but this is premature
>
> We agree then :-)
>
>    Andrew

I also agree with all of your points, but hope this is not something
that would prevent this patch series from being acceptable.  It could
be quite an effort to try and properly document the code and what it
is doing, get HW to verify the assumptions from the documentation (as
the MIPS HW was done by a different group, no hardware is available,
etc), relocate the code to the drivers/net/phy and add a standard
interface.  From your original comment, I believe that you agree that
this additional effort is not necessary at this point in time.

Thanks,
Jon
