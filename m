From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [RFC PATCH v3 0/5] net: dsa: cleanup dsa driver
Date: Mon, 7 Dec 2015 11:25:57 +0100
Message-ID: <56655EB5.6080600@baylibre.com>
References: <56323100.9000304@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35944 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754824AbbLGK0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 05:26:00 -0500
Received: by wmww144 with SMTP id w144so134132483wmw.1
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 02:25:59 -0800 (PST)
In-Reply-To: <56323100.9000304@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2015 03:45 PM, Neil Armstrong wrote:
> Introduce a new remove callback to allow DSA drivers to cleanup their
> ressources.
> Then add a remove implementation for bcm_sf2 and mv88e6xxx.
> 
> This patch was not tested due of a lack of hardware.
> 
> v2: add remove callback patch to the serie
> v3: separate & fix ppu remove callback into a proper patch
> 
> Neil Armstrong (5):
>   net: dsa: allow switch drivers to cleanup their resources
>   net: dsa: bcm_sf2: cleanup resources in remove callback
>   net: dsa: mv88e6xxx: add common remove function
>   net: dsa: make usage of mv88e6xxx common remove function
>   net: dsa: add mv88e6xxx ppu remove function for mv88e6131
> 
>  drivers/net/dsa/bcm_sf2.c         | 20 ++++++++++++++++++++
>  drivers/net/dsa/mv88e6123_61_65.c |  1 +
>  drivers/net/dsa/mv88e6131.c       |  8 ++++++++
>  drivers/net/dsa/mv88e6171.c       |  1 +
>  drivers/net/dsa/mv88e6352.c       |  1 +
>  drivers/net/dsa/mv88e6xxx.c       | 18 ++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx.h       |  2 ++
>  include/net/dsa.h                 |  1 +
>  net/dsa/dsa.c                     |  4 ++++
>  9 files changed, 56 insertions(+)
> 

Hi All,

Did someone had a chance to test this ?

Having such code will help for the final DSA reworking.

Neil
