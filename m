From: Erik Slagter <erik@slagter.name>
Subject: Re: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Mon, 30 Jul 2007 11:27:55 +0200
Message-ID: <46ADAF1B.4060500@slagter.name>
References: <467915D9.3030900@slagter.name>	<1182523020.4938.20.camel@dhollis-lnx.sunera.com>	<467FF5DB.5090006@slagter.name> <1182923692.6644.4.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Hollis <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from erik-slagter.demon.nl ([83.160.41.216]:46505 "EHLO
	artemis.slagter.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932932AbXG3J15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 05:27:57 -0400
In-Reply-To: <1182923692.6644.4.camel@dhollis-lnx.sunera.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Hollis wrote:
> On Mon, 2007-06-25 at 19:05 +0200, Erik Slagter wrote:
>> drivers/net/usb/asix.c: PHYID=0x01410cc2
> 
> Ok, it is using a Marvell PHY so that part should be fine.  You
> mentioned that it looks like the packets are being transmitted, but are
> garbled in some way.  The device does prepend a 'header' to ethernet
> packets as they are transmitted down the USB pipe.  The device strips
> this off and puts the packets on the wire.  This could be where the
> issue lies.  Are you on x86 by chance or something else?

They are either garbled are they are not passed on the wire. The
transmitted packets are shown by tshark, but a tshark run on "the other
end of the line" does not show them.

Platform is indeed x86, to be precise: fedora 7, kernel 2.6.22-rc6, cpu
pentium M, dell laptop inspiron 9300, ICH6.

If you want me to test something please yell, it's no trouble at all to
change a few lines in the driver's source and recompile the module.

Please note I cannot send mail to you: "(conversation with
dhollis.dyndns.org[71.251.104.159] timed out while sending MAIL FROM)"

