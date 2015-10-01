From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [patch net-next v3 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Thu, 1 Oct 2015 13:11:48 -0400
Message-ID: <20151001171147.GA24533@ketchup.mtl.sfl>
References: <20150925043640.GB18915@ketchup.lan>
 <CAE4R7bA=xwfNT1cEp7_B7zfiuqg=PZ421j+GNCP+hi9DrhccAA@mail.gmail.com>
 <20150924.225508.2124748200966556070.davem@davemloft.net>
 <20150925150303.GA21567@ketchup.mtl.sfl>
 <20150930185652.GA2455@ketchup.lan>
 <CAE4R7bBooYJTBTUpb6zCRfoZs4N9VW1exfFBZgY5B1FmdQVtpg@mail.gmail.com>
 <20151001151535.GA31603@ketchup.mtl.sfl>
 <20151001152821.GK20219@lunn.ch>
 <20151001161706.GA1836@ketchup.mtl.sfl>
 <20151001162620.GO20219@lunn.ch>
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
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:33262
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753295AbbJARLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 13:11:50 -0400
Content-Disposition: inline
In-Reply-To: <20151001162620.GO20219@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Oct. Thursday 01 (40) 06:26 PM, Andrew Lunn wrote:
> > DSA drivers don't need dynamic resources from the kernel.
> 
> It is hard to say if that is going to remain true. I think when we
> start doing more D in DSA, we might need to keep more state
> information.

Maybe, but we should keep things simple and do not use complex
structures until we need them.

> What we need to avoid is making changes now that we later need to undo
> because we need dynamic resources. So i'm happy for a simple
> interface, so long as i can still use the complex interface, when i
> need it.

Yes, note that I don't want to get rid of switchdev_trans here.

I want to explicitly skip it in the DSA framework (net/dev/slave.c)
while allowing DSA drivers (e.g. mv88e6xxx.c) to tell us if a feature
object is supported or not.

Thanks,
-v
