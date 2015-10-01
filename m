From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next v3 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Thu, 1 Oct 2015 18:26:20 +0200
Message-ID: <20151001162620.GO20219@lunn.ch>
References: <1443081769-11193-3-git-send-email-jiri@resnulli.us>
 <20150925043640.GB18915@ketchup.lan>
 <CAE4R7bA=xwfNT1cEp7_B7zfiuqg=PZ421j+GNCP+hi9DrhccAA@mail.gmail.com>
 <20150924.225508.2124748200966556070.davem@davemloft.net>
 <20150925150303.GA21567@ketchup.mtl.sfl>
 <20150930185652.GA2455@ketchup.lan>
 <CAE4R7bBooYJTBTUpb6zCRfoZs4N9VW1exfFBZgY5B1FmdQVtpg@mail.gmail.com>
 <20151001151535.GA31603@ketchup.mtl.sfl>
 <20151001152821.GK20219@lunn.ch>
 <20151001161706.GA1836@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48639 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923AbbJAQ00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 12:26:26 -0400
Content-Disposition: inline
In-Reply-To: <20151001161706.GA1836@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> DSA drivers don't need dynamic resources from the kernel.

It is hard to say if that is going to remain true. I think when we
start doing more D in DSA, we might need to keep more state
information.

What we need to avoid is making changes now that we later need to undo
because we need dynamic resources. So i'm happy for a simple
interface, so long as i can still use the complex interface, when i
need it.

     Andrew
