From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC v2 18/32] dsa: mv88e6xxx: Prepare for turning this into a library module
Date: Sun, 28 Feb 2016 21:40:56 -0500
Message-ID: <87io185jd3.fsf@ketchup.mtl.sfl>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch> <1456677700-23027-19-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49607 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbcB2ClA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 21:41:00 -0500
In-Reply-To: <1456677700-23027-19-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Export all the functions so that we can later turn the module into a
> library module.

As I mentioned in the first RFC [1], wouldn't that be preferable to
avoid adding modules and factorize everything into a single one?

The common code would have a single probe function which calls
mv88e6xxx_lookup_name for every model tables until it finds the good
one.

For the rest of the code, a few additional switch family checks should
do the job. What do you think?

[1] https://patchwork.ozlabs.org/patch/560540/

Thanks,

        -v
