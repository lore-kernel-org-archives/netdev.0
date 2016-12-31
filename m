From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] net: ethernet: faraday: To support device tree usage.
Date: Sat, 31 Dec 2016 21:23:58 +0100
Message-ID: <6434425.l4ZxB6kK6L@wuerfel>
References: <1483083470-15779-1-git-send-email-green.hu@gmail.com> <351d1ae7-ca51-7962-0e52-38cdc69bcebd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Greentime Hu <green.hu@gmail.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, andrew@lunn.ch,
        linux-kernel@vger.kernel.org, jiri@resnulli.us
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:64597 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750717AbcLaUYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2016 15:24:09 -0500
In-Reply-To: <351d1ae7-ca51-7962-0e52-38cdc69bcebd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, December 31, 2016 10:48:39 AM CET Florian Fainelli wrote:
> 
> On 12/29/2016 11:37 PM, Greentime Hu wrote:
> > Signed-off-by: Greentime Hu <green.hu@gmail.com>
> 
> This is not enough, you need to add a Device Tree binding document under
> Documentation/devicetree/bindings/net/ which documents this compatible
> string, as well as additional properties that may be required to
> describe this hardware block.

We already have

Documentation/devicetree/bindings/net/moxa,moxart-mac.txt

for the same hardware (though used by a different driver).

I'd suggest renaming that one to a more generic file name and
adding the new compatible string there.

Aside from that, every patch should also have a changelog comment.

	Arnd
