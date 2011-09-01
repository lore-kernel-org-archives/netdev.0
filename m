From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH] mii: Remove references to DP83840 PHY in mii.h
Date: Thu, 1 Sep 2011 10:22:47 +0100
Message-ID: <CANK3SE1PMRsYh+2ZEdh+dW9UiGthhkHjattscNgZuf8U9kUb3Q@mail.gmail.com>
References: <1314804928-7353-1-git-send-email-mark.einon@gmail.com>
	<1314812070.3274.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:46639 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab1IAJWs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 05:22:48 -0400
Received: by ywf7 with SMTP id 7so1239165ywf.19
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2011 02:22:47 -0700 (PDT)
In-Reply-To: <1314812070.3274.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31 August 2011 18:34, Ben Hutchings <bhutchings@solarflare.com> wrot=
e:
>
> Since you're trying to improve these comments, I think this could do
> with further improvement. =A0When this bit is set, the PHY's data pat=
hs
> are isolated from the MII (or other interface to the MAC). =A0The con=
trol
> path is still connected to the management interface (MDIO), which is
> important when we want to clear this bit! =A0So it would be better to=
 say
> something like 'Isolate data paths fromn MII'.

>
> This selects a low-power state (if implemented). =A0It doesn't entire=
ly
> turn the PHY off, and at least the management interface must stil be
> functional. =A0So it would be better to say 'Request low-power state'=
=2E

Hi Ben,

=46air points, hope I've addressed these in the revised patch.

> This formatting change is unrelated. =A0If you're going to fix format=
ting
> then please convert spaces to tabs after each name and value.
>

Done, and broken out into a separate patch.

Cheers,

Mark
