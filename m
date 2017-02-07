From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: Allow splitting MDIO bus/device
 support from PHYs
Date: Mon, 6 Feb 2017 16:23:24 -0800
Message-ID: <f4972545-d4f4-62bc-b705-d26ca856b798@gmail.com>
References: <20170207001112.1282-1-f.fainelli@gmail.com>
 <20170207002143.GP27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33891 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdBGAX0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 19:23:26 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so7901526pfb.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 16:23:26 -0800 (PST)
In-Reply-To: <20170207002143.GP27312@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2017 04:21 PM, Russell King - ARM Linux wrote:
> On Mon, Feb 06, 2017 at 04:11:12PM -0800, Florian Fainelli wrote:
>> Introduce a new configuration symbol: MDIO_DEVICE which allows building
>> the MDIO devices and bus code, without pulling in the entire Ethernet
>> PHY library and devices code.
>>
>> PHYLIB nows select MDIO_DEVICE and the relevant Makefile files are
>> updated to reflect that.
> 
> I think you've been a little too quick off the mark posting this -
> see my points raised in reply to your RFC.  This will cause problems
> when built as a module, not least the missing MODULE_LICENSE()s.
> 

Yes, good point, let me fix that.
-- 
Florian
