From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 0/2] net: dsa: integration with SWITCHDEV for HW bridging
Date: Tue, 17 Feb 2015 17:09:25 -0800
Message-ID: <54E3E645.3070701@gmail.com>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <CAE4R7bDFJn=ZMNDnDovY62eQyv4aSBR0VdhB8yoF+JLCTaS+kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33345 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414AbbBRBJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 20:09:41 -0500
Received: by pabkx10 with SMTP id kx10so10488509pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 17:09:40 -0800 (PST)
In-Reply-To: <CAE4R7bDFJn=ZMNDnDovY62eQyv4aSBR0VdhB8yoF+JLCTaS+kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/02/15 16:48, Scott Feldman wrote:
> On Tue, Feb 17, 2015 at 2:26 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> Hi all,
>>
>> This patchset is mostly to demonstrate how we could integrate with SWITCHDEV
>> to provide HW bridging support for DSA switch drivers that are currently in
>> tree. Since 'net-next' is currently closed, this gives us some time to work
>> on the abstraction we want to have in DSA to facilitate our life.
>>
>> Attached is an example of how this winds up looking like for the bcm_sf2 driver.
> 
> It looks good Florian.
> 
> Does bcm_sf2 do mac/vlan learning?
> 

Yes, it can do that, that's next on my list of things to get working ;)
-- 
Florian
