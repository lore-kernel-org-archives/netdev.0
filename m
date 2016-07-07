From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 6/7] dt-bindings: net: bgmac: add bindings documentation
 for bgmac
Date: Thu, 7 Jul 2016 18:42:22 -0400
Message-ID: <CAC3K-4qnnbG2c8rQWhUx+ZTOvLKrKL+iZ3=WVZ1tuXCixHV3gw@mail.gmail.com>
References: <1467327554-22074-1-git-send-email-jon.mason@broadcom.com>
 <3327458.KVBg7y9SeP@wuerfel> <CAC3K-4qZ9tpEAuDBjL-bkjn5F2Xfr4CAmVGc=DpgVh8MrqEDtQ@mail.gmail.com>
 <13160704.EGDxD1URaF@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Ray Jui <ray.jui@broadcom.com>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Branden <sbranden@broadcom.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	linux-kernel@vger.kernel.org, Ray Jui <rjui@broadcom.com>,
	Rob Herring <robh+dt@kernel.org>,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	Kumar Gala <galak@codeaurora.org>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34251 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbcGGWmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 18:42:25 -0400
Received: by mail-io0-f174.google.com with SMTP id i186so33196707iof.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 15:42:25 -0700 (PDT)
In-Reply-To: <13160704.EGDxD1URaF@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 3:34 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Tuesday, July 5, 2016 7:18:45 PM CEST Jon Mason wrote:
>> >
>> > Ok, then I'd suggest making the compatible string here
>> >
>> >         compatible = "brcm,nsp-amac", "brcm,amac";
>>
>> It is called GMAC in the NS and NSP documentation, but AMAC is fine
>> with me (as it is called this in the NS2 documentation).  I'll make
>> the necessary change and repush.
>
> Ok, then we can use
>
>         compatible = "brcm,nsp-gmac", "brcm,amac";
>
> to be consistent with that documentation and have the generic name as the
> fallback.

After looking at the docs again, I see the blocks being referred to as
"AXI MAC" (while the registers are being called GMAC).  To keep it
consistent, I'll just change everything to be "amac".

Thanks,
Jon

>
>         Arnd
