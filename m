From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next 00/26] bonding/team offload + mlxsw
 implementation
Date: Wed, 2 Dec 2015 16:27:18 +0100
Message-ID: <20151202152718.GM29814@lunn.ch>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <20151201144300.GB2165@nanopsycho.orion>
 <CAJ3xEMhMACJe_iK4PTrGwGFHzgGM=ccNKjVBoC6SUfCo0w7xFQ@mail.gmail.com>
 <20151201151243.GC2165@nanopsycho.orion>
 <CAJ3xEMjRQQoo=uU0qQ5Z9UmvS0_QjB2q_LUrpfBWLtTpHhd3qw@mail.gmail.com>
 <20151201164719.GA2548@nanopsycho>
 <CAJ3xEMiSA70nDsBWUmv=J6Cy2rt4+iNTg+4Yeqy=810etVAPZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>, pjonnala@broadcom.com,
	Jay Vosburgh <j.vosburgh@gmail.com>, vfalico@gmail.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	john fastabend <john.fastabend@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51587 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494AbbLBP1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 10:27:23 -0500
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiSA70nDsBWUmv=J6Cy2rt4+iNTg+4Yeqy=810etVAPZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Another question relates to users bonding/teaming netdevice ports from
> different HW switches

We need to be precises here.

DSA allows for a cluster of switches which are interconnected via
switch ports. In this setup, the Marvell switches allows ports of
different switches to be members of a trunk, which is Marvells name
for a bond/team.

The second possible setup would be multiple switch devices which are
not interconnected. Packets would then have to be forwarded from one
switch to another via the CPU when a bond/team is spread across
switches.

	Andrew
