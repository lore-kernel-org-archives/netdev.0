From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v3 00/12] net-caif: introducing CAIF
 protocol stack
Date: Fri, 26 Feb 2010 01:22:04 -0800 (PST)
Message-ID: <20100226.012204.67216627.davem@davemloft.net>
References: <1266876331-23988-1-git-send-email-sjur.brandeland@stericsson.com>
	<1266910387.18491.54.camel@violet>
	<61D8D34BB13CFE408D154529C120E07903359AE7@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, netdev@vger.kernel.org,
	daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935653Ab0BZJVq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 04:21:46 -0500
In-Reply-To: <61D8D34BB13CFE408D154529C120E07903359AE7@eseldmw101.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Tue, 23 Feb 2010 08:39:52 +0100

> Hi Marcel.
>>> CHANGE LOG:
>>> Based on review comments from David Miller and Marcel Holtmann on t=
he
>>> previous patch set submitted the 16 February the following changes
>>> have been done:=20
>>> - Removed ifdef __cplusplus from caif_socket.h
>>> - Use socket level SOL_IP for socket options SO_PRIORITY and
>>> SO_BINDTODEVICE
>>=20
>> are you sure it is not better to use SOL_SOCKET here. At least
>> according to man 7 socket this would make a lot more sense. My point
>> in actually using SO_PRIORITY and SO_BINDTODEVICE is to use standard
>> socket options that are already used by everybody else. So they know
>> what to expect.   =20
>>=20
> Yes, this makes sense. I'll update this.

Please fix this up and resubmit your patch series so I can add
it to the net-next-2.6 tree.
