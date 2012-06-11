From: Alessandro Rubini <rubini@gnudd.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Mon, 11 Jun 2012 16:23:11 +0200
Message-ID: <20120611142311.GA28682@mail.gnudd.com>
References: <4FD5F7F1.3010602@grandegger.com>
  <20120604165619.15ba43bf@pyramind.ukuu.org.uk>
  <4FC135C6.5030206@grandegger.com>
  <1338816766-7089-1-git-send-email-federico.vaga@gmail.com>
  <1338816766-7089-2-git-send-email-federico.vaga@gmail.com>
 <20120604164531.GA22000@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, federico.vaga@gmail.com,
	mkl@pengutronix.de, giancarlo.asnaghi@st.com, alan@linux.intel.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.gnudd.com ([213.203.150.91]:56396 "EHLO mail.gnudd.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752286Ab2FKOXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 10:23:33 -0400
Content-Disposition: inline
In-Reply-To: <4FD5F7F1.3010602@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> In my opinion, it would be much better to have one less layer and no
>> exports at all. The core driver should be a platform driver, and the
>> pci driver would just build platform data and register the platform
>> device.
> 
> Do you have examples for that approach? Not sure yet if it really saves
> code and makes it more readable.

Maybe the physmap mtd driver is a good example. Everybody's using it
(but not from PCI). I found drivers/pcmcia/bcm63xx_pcmcia.c that
registers a platform driver from a pci probe function, but I'm sure
there are other ones.

OTOH, I have another example of how not to do stuff, but I won't point
fingers now (it's not a CAN thing).

I just think the platform bus is there just for this reason: to provide
data to a generic driver, without module dependencies and such stuff. 

> I would suggest to provide the c_can_pci driver using the *current* API,
> even if it's not optimal. Federicos patch then already looks quite good.
> It should use the new register access methods introduced by the D_CAN
> support patch, though.

Great. When it's in I'll show my proposal as an RFC patch, as time permits,
so we'll see if it's better or not.

> Any further improvements to the device abstraction and a more consistent
> handling of the platform data are welcome.

Good to know, thanks a lot

/alessandro
