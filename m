From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH RFC 0/2] net: dsa: integration with SWITCHDEV for HW bridging
Date: Tue, 17 Feb 2015 19:48:24 -0500
Message-ID: <CAE4R7bDFJn=ZMNDnDovY62eQyv4aSBR0VdhB8yoF+JLCTaS+kw@mail.gmail.com>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:60255 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbbBRAsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 19:48:25 -0500
Received: by mail-qa0-f47.google.com with SMTP id v10so28948786qac.6
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 16:48:24 -0800 (PST)
In-Reply-To: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2015 at 2:26 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Hi all,
>
> This patchset is mostly to demonstrate how we could integrate with SWITCHDEV
> to provide HW bridging support for DSA switch drivers that are currently in
> tree. Since 'net-next' is currently closed, this gives us some time to work
> on the abstraction we want to have in DSA to facilitate our life.
>
> Attached is an example of how this winds up looking like for the bcm_sf2 driver.

It looks good Florian.

Does bcm_sf2 do mac/vlan learning?
