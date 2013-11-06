From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM
 emac driver
Date: Tue, 5 Nov 2013 18:23:52 -0800
Message-ID: <CAGVrzcZ+Qdjp4hdLREgvgLgNgQxPObJ8u_wD8-3MGy9rGxfHow@mail.gmail.com>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au>
 <81419762.0SyAdYsUqu@mexican> <CAGVrzcYzBtDcxYXDopOJn_=vW_58SFs9y0uKeGNB9TDPh6J4wg@mail.gmail.com>
 <9250529.5UedqhaNce@mexican> <1383704240.4776.115.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alistair Popple <alistair@popple.id.au>,
	netdev <netdev@vger.kernel.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	"David S. Miller" <davem@davemloft.net>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:56307 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050Ab3KFCYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 21:24:33 -0500
Received: by mail-pd0-f176.google.com with SMTP id g10so9437105pdj.21
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 18:24:32 -0800 (PST)
In-Reply-To: <1383704240.4776.115.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/11/5 Benjamin Herrenschmidt <benh@kernel.crashing.org>:
> On Wed, 2013-11-06 at 12:38 +1100, Alistair Popple wrote:
>> > Right, rgmii_mode_name() just has informative purposes and should be
>> > removed, I would suggest using standard device tree bindings
>> property
>> > (phy-mode) anyway such that you could use of_get_phy_mode() and use
>> > phy_interface_t types.
>>
>> Ok, that's what is currently done in the core IBM EMAC driver. As this
>> is used
>> just for informative purposes I will remove it. Thanks.
>
> Why ? Information is useful...

Not the way they are currently handled:

+       /* Check if we need to attach to a RGMII */
+       if (!rgmii_valid_mode(mode)) {
+               dev_err(&ofdev->dev, "unsupported settings !\n");

Considering that nothing useful is being printed, that or nothing at
all really looks identical to me.
--
Florian
