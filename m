From: jamal <hadi@cyberus.ca>
Subject: Re: Network drivers that don't suspend on interface down
Date: Thu, 21 Dec 2006 08:14:29 -0500
Message-ID: <1166706869.3749.29.camel@localhost>
References: <20061220042648.GA19814@srcf.ucam.org>
	 <20061220144906.7863bcd3@dxpl.pdx.osdl.net>
	 <20061221011209.GA32625@srcf.ucam.org>
	 <200612202105.31093.flamingice@sourmilk.net>
	 <20061221021832.GA723@srcf.ucam.org>
	 <1166670848.23168.21.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: stefan@loplof.de, Matthew Garrett <mjg59@srcf.ucam.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161098AbWLUNOe@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1166670848.23168.21.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-20-12 at 22:14 -0500, Dan Williams wrote:
...
....
> Simple == good.  Down == down.  Lets just agree on that and save
> ourselves a lot of pain.

netdevices have well defined operational and administrative state
machines. And very well defined relationship between operational and
administrative status. IOW, care should be invoked not to reinvent.

Power management to me seems like an operational state.
A link could only transition to operational or down depending on 
whether it is "powered" up or down.

To be complete, since a netdevice is a generic construct, nota bene:
- a link could be a wireless association or ethernet cable or a PPP
session or a ATM PVC, or an infrared channel etc. 
- events that result in operational link transitions could be anything
from powering up an ethernet phy with an active cable plugged to an
802.1x auth on a wireless association to a on-demand ppp link seeing an
outgoing packet.

IMO, for this discussion to be meaningful, it would be useful to read
Documentation/networking/operstates.txt
And if you are keen you can then read RFC 2863...

cheers,
jamal
