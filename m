From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 01/16] dsa: slave: chip data is optional, don't dereference NULL
Date: Fri, 27 May 2016 14:45:46 -0400
Message-ID: <87inxzz6ed.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34482 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550AbcE0Spu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 14:45:50 -0400
In-Reply-To: <1464312050-23023-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, Florian,

We are inconsistent on commit titles and messages. Some of them use
"net: " prefix, some others don't, sometimes lower or upper case titles.

I'd suggest we stick with the "net: dsa: " prefix and lowercase titles.

When possible, let's try to respect the 50/72 Git rule.

So we'd have e.g.:

    net: dsa: add new bindings
    net: dsa: mv88e6xxx: add support for foo
    net: dsa: sf2: remove bar
    ...

The networking documentation doesn't seem to have opinion on the "net: "
prefix. We might drop it and keep only "dsa: " for core and drivers.

What do you think?

Thanks,

        Vivien
