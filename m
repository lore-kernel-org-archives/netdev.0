From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 03/11] net: mvmdio: use GENMASK for masks
Date: Mon, 19 Jun 2017 11:57:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0025C9A@AcuExch.aculab.com>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
 <20170614154911.14510-4-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        "nadavh@marvell.com" <nadavh@marvell.com>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: 'Antoine Tenart' <antoine.tenart@free-electrons.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.195]:64017 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753845AbdFSL6B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 07:58:01 -0400
In-Reply-To: <20170614154911.14510-4-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart
> Sent: 14 June 2017 16:49
> Cosmetic patch to use the GENMASK helper for masks.
...
> -	ret = val & 0xFFFF;
> +	ret = val & GENMASK(15, 0);

My 2c: It isn't at all clear to me that changes like this in anyway
improve the code readability.
In some sense the '15' should be a named constant - but that just makes
it even less obvious what is going on.

	David
