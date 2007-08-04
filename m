From: Erik Slagter <erik@slagter.name>
Subject: Re: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Sat, 04 Aug 2007 18:24:06 +0200
Message-ID: <46B4A826.7010705@slagter.name>
References: <467915D9.3030900@slagter.name>	<1182523020.4938.20.camel@dhollis-lnx.sunera.com>	<467FF5DB.5090006@slagter.name>	<1182923692.6644.4.camel@dhollis-lnx.sunera.com>	<46ADAF1B.4060500@slagter.name> <1185820074.8086.4.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms020805010300020608050602"
Cc: netdev@vger.kernel.org
To: David Hollis <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from erik-slagter.demon.nl ([83.160.41.216]:57771 "EHLO
	artemis.slagter.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761222AbXHDQYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2007 12:24:11 -0400
In-Reply-To: <1185820074.8086.4.camel@dhollis-lnx.sunera.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms020805010300020608050602
Content-Type: multipart/mixed;
 boundary="------------020607090002040603020609"

This is a multi-part message in MIME format.
--------------020607090002040603020609
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

David Hollis wrote:

>> They are either garbled are they are not passed on the wire. The
>> transmitted packets are shown by tshark, but a tshark run on "the other
>> end of the line" does not show them.
>>
>> Platform is indeed x86, to be precise: fedora 7, kernel 2.6.22-rc6, cpu
>> pentium M, dell laptop inspiron 9300, ICH6.
>>
>> If you want me to test something please yell, it's no trouble at all to
>> change a few lines in the driver's source and recompile the module.
>> 
> Could you send me a complete dmesg dump when the driver is compiled with
> DEBUG enabled (at least from then usb logs that the device was inserted
> to the end).  I'll need to see what it reports the values of the
> registers.

Please see attachment.

> Have you tried using the F7 2.6.22 kernel?  I know that has worked fine
> for me on my system.

I tried vanilla 2.6.22 and now 2.6.23-rc1

>> Please note I cannot send mail to you: "(conversation with
>> dhollis.dyndns.org[71.251.104.159] timed out while sending MAIL FROM)"
> 
> I've fixed that issue so my mail delivery isn't sporadic.

I still got it last week.

--------------020607090002040603020609
Content-Type: text/plain;
 name="dmesg.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dmesg.txt"

usb 1-8: new high speed USB device using ehci_hcd and address 11
usb 1-8: configuration #1 chosen from 1 choice
usb%d: asix_read_cmd() cmd=0x1e value=0x0000 index=0x0000 size=1
drivers/net/usb/asix.c: GPIO Status: 0x0002
usb%d: asix_write_cmd() cmd=0x0d value=0x0000 index=0x0000 size=0
usb%d: asix_read_cmd() cmd=0x0b value=0x0017 index=0x0000 size=2
usb%d: asix_write_cmd() cmd=0x0e value=0x0000 index=0x0000 size=0
drivers/net/usb/asix.c: EEPROM index 0x17 is 0x0580
drivers/net/usb/asix.c: GPIO0: 0, PhyMode: 0
usb%d: asix_write_gpio() - value = 0x008c
usb%d: asix_write_cmd() cmd=0x1f value=0x008c index=0x0000 size=0
usb%d: asix_write_gpio() - value = 0x003c
usb%d: asix_write_cmd() cmd=0x1f value=0x003c index=0x0000 size=0
usb%d: asix_write_gpio() - value = 0x001c
usb%d: asix_write_cmd() cmd=0x1f value=0x001c index=0x0000 size=0
usb%d: asix_write_gpio() - value = 0x003c
usb%d: asix_write_cmd() cmd=0x1f value=0x003c index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x20 value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x20 value=0x0048 index=0x0000 size=0
usb%d: asix_write_rx_ctl() - mode = 0x0000
usb%d: asix_write_cmd() cmd=0x10 value=0x0000 index=0x0000 size=0
usb%d: asix_read_cmd() cmd=0x13 value=0x0000 index=0x0000 size=6
usb%d: asix_get_phy_addr()
usb%d: asix_read_cmd() cmd=0x19 value=0x0000 index=0x0000 size=2
usb%d: asix_get_phy_addr() returning 0x18e0
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0002 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_mdio_read() phy_id=0x18, loc=0x02, returns=0x0141
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0003 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_mdio_read() phy_id=0x18, loc=0x03, returns=0x0cc2
drivers/net/usb/asix.c: PHYID=0x01410cc2
usb%d: marvell_phy_init()
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_read_cmd() cmd=0x07 value=0x0018 index=0x001b size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_mdio_read() phy_id=0x18, loc=0x1b, returns=0x848f
usb%d: MII_MARVELL_STATUS = 0x848f
usb%d: asix_mdio_write() phy_id=0x18, loc=0x14, val=0x0082
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x08 value=0x0018 index=0x0014 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0018 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_mdio_read() phy_id=0x18, loc=0x18, returns=0x4100
usb%d: MII_MARVELL_LED_CTRL (1) = 0x4100
usb%d: asix_mdio_write() phy_id=0x18, loc=0x18, val=0x4101
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x08 value=0x0018 index=0x0018 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0018 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_mdio_read() phy_id=0x18, loc=0x18, returns=0x4101
usb%d: MII_MARVELL_LED_CTRL (2) = 0x4101
usb%d: asix_mdio_write() phy_id=0x18, loc=0x00, val=0x9000
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x08 value=0x0018 index=0x0000 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_mdio_write() phy_id=0x18, loc=0x04, val=0x05e1
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x08 value=0x0018 index=0x0004 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_mdio_write() phy_id=0x18, loc=0x09, val=0x0200
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x08 value=0x0018 index=0x0009 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0000 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_mdio_read() phy_id=0x18, loc=0x00, returns=0x1000
usb%d: asix_mdio_write() phy_id=0x18, loc=0x00, val=0x1200
usb%d: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
usb%d: asix_write_cmd() cmd=0x08 value=0x0018 index=0x0000 size=2
usb%d: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
usb%d: asix_write_medium_mode() - mode = 0x0376
usb%d: asix_write_cmd() cmd=0x1b value=0x0376 index=0x0000 size=0
usb%d: asix_write_rx_ctl() - mode = 0x0088
usb%d: asix_write_cmd() cmd=0x10 value=0x0088 index=0x0000 size=0
eth2: register 'asix' at usb-0000:00:1d.7-8, ASIX AX88178 USB 2.0 Ethernet, 00:12:17:f2:1a:17
usbcore: registered new interface driver asix
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0001 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x01, returns=0x7949
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0001 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x01, returns=0x7949
eth2: ax88178_link_reset()
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0001 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x01, returns=0x7949
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0001 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x01, returns=0x7949
eth2: link down
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0004 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x04, returns=0x05e1
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0009 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x09, returns=0x0200
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0000 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x00, returns=0x1000
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0005 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x05, returns=0x0000
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0009 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x09, returns=0x0200
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x000a size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x0a, returns=0x0000
eth2: ax88178_link_reset() speed: 10 duplex: 0 setting mode to 0x0174
eth2: asix_write_medium_mode() - mode = 0x0174
eth2: asix_write_cmd() cmd=0x1b value=0x0174 index=0x0000 size=0
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0019 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x19, returns=0x0000
eth2: marvell_led_status() read 0x0000
eth2: marvell_led_status() writing 0x02f0
eth2: asix_mdio_write() phy_id=0x18, loc=0x19, val=0x02f0
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_write_cmd() cmd=0x08 value=0x0018 index=0x0019 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_write_cmd_async() cmd=0x10 value=0x0088 index=0x0000 size=0
eth2: asix_write_cmd_async() cmd=0x16 value=0x0000 index=0x0000 size=8
eth2: asix_write_cmd_async() cmd=0x10 value=0x0098 index=0x0000 size=0
eth2: asix_write_cmd_async() cmd=0x16 value=0x0000 index=0x0000 size=8
eth2: asix_write_cmd_async() cmd=0x10 value=0x0098 index=0x0000 size=0
r8169: eth1: link down
eth2: Link Status is: 1
eth2: ax88178_link_reset()
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0001 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x01, returns=0x796d
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0001 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x01, returns=0x796d
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0004 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x04, returns=0x05e1
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0005 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x05, returns=0xc5e1
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x000a size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x0a, returns=0x3800
eth2: link up, 1000Mbps, full-duplex, lpa 0xC5E1
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0004 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x04, returns=0x05e1
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0009 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x09, returns=0x0200
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0000 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x00, returns=0x1000
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0005 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x05, returns=0xc5e1
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0009 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x09, returns=0x0200
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x000a size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x0a, returns=0x3800
eth2: ax88178_link_reset() speed: 1000 duplex: 1 setting mode to 0x037f
eth2: asix_write_medium_mode() - mode = 0x037f
eth2: asix_write_cmd() cmd=0x1b value=0x037f index=0x0000 size=0
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_read_cmd() cmd=0x07 value=0x0018 index=0x0019 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
eth2: asix_mdio_read() phy_id=0x18, loc=0x19, returns=0x02f0
eth2: marvell_led_status() read 0x02f0
eth2: marvell_led_status() writing 0x03e0
eth2: asix_mdio_write() phy_id=0x18, loc=0x19, val=0x03e0
eth2: asix_write_cmd() cmd=0x06 value=0x0000 index=0x0000 size=0
eth2: asix_write_cmd() cmd=0x08 value=0x0018 index=0x0019 size=2
eth2: asix_write_cmd() cmd=0x0a value=0x0000 index=0x0000 size=0
device eth2 entered promiscuous mode
eth2: asix_write_cmd_async() cmd=0x10 value=0x0089 index=0x0000 size=0
eth2: asix_write_cmd_async() cmd=0x10 value=0x0089 index=0x0000 size=0
device eth2 left promiscuous mode
eth2: asix_write_cmd_async() cmd=0x16 value=0x0000 index=0x0000 size=8
eth2: asix_write_cmd_async() cmd=0x10 value=0x0098 index=0x0000 size=0
eth2: asix_write_cmd_async() cmd=0x16 value=0x0000 index=0x0000 size=8
eth2: asix_write_cmd_async() cmd=0x10 value=0x0098 index=0x0000 size=0
eth2: asix_write_cmd_async() cmd=0x16 value=0x0000 index=0x0000 size=8
eth2: asix_write_cmd_async() cmd=0x10 value=0x0098 index=0x0000 size=0
eth2: asix_write_cmd_async() cmd=0x16 value=0x0000 index=0x0000 size=8
eth2: asix_write_cmd_async() cmd=0x10 value=0x0098 index=0x0000 size=0
eth2: asix_write_cmd_async() cmd=0x16 value=0x0000 index=0x0000 size=8
eth2: asix_write_cmd_async() cmd=0x10 value=0x0098 index=0x0000 size=0
eth2: asix_write_cmd_async() cmd=0x16 value=0x0000 index=0x0000 size=8
eth2: asix_write_cmd_async() cmd=0x10 value=0x0098 index=0x0000 size=0
device eth2 entered promiscuous mode
eth2: asix_write_cmd_async() cmd=0x10 value=0x0089 index=0x0000 size=0
device eth2 left promiscuous mode
eth2: asix_write_cmd_async() cmd=0x16 value=0x0000 index=0x0000 size=8
eth2: asix_write_cmd_async() cmd=0x10 value=0x0098 index=0x0000 size=0

--------------020607090002040603020609--

--------------ms020805010300020608050602
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIJUTCC
AwMwggJsoAMCAQICEH7+jMMkILvfMGzj+Ok1nw8wDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UE
BhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMT
I1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA2MTAxMTA4MjIxMVoX
DTA3MTAxMTA4MjIxMVowajEQMA4GA1UEBBMHU2xhZ3RlcjEVMBMGA1UEKhMMRXJpayBNYXJ0
aWpuMR0wGwYDVQQDExRFcmlrIE1hcnRpam4gU2xhZ3RlcjEgMB4GCSqGSIb3DQEJARYRZXJp
a0BzbGFndGVyLm5hbWUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDM5rtCRQmb
ZzxbezId4+cmqrIzzR8ZMxyPH4pMsrPLe1L9SwbzWZbPZZEY47tmeEJv4JZHo6FpSscXHj5Y
pk2i6l+u9HrvexKVZVo6bO8zEJGNWaWbE0Y/4wUhsvlQw8ssRMDNZb6YR3SADHgTtuPgChqj
DxX1jnQK+vFxk3s/ub55nOWjzRItqPWJNuRac5esv5DSR43TQm0YujoAXPnswzr2l1y4oCKQ
iPIrf5erlK60N4d9US3EPpCkByGyyYQ7IE75NB5E/kCfNV8g41bpJIB6sobCUl+faHozSD/c
AfrYhRNCj//LkG5q5EtKoKSFMKSZoVmwUsv77M/GJpXbAgMBAAGjLjAsMBwGA1UdEQQVMBOB
EWVyaWtAc2xhZ3Rlci5uYW1lMAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEFBQADgYEAPF1+
u8w++Z8aqKBPN9yEHt+u/GC5cBHLTE0ltBuPKDdUr5POL1yrJsWsFgaj2/MPA2w+dF4dcZmz
7DKpClL2+06FdXmUa7hOzpw4HgS2riznlIT0KuobhDjxj9V/W1dzAp2NwwlsuIz60/t2w97b
5miMwlNioNq9CoXOIiSxI2EwggMDMIICbKADAgECAhB+/ozDJCC73zBs4/jpNZ8PMA0GCSqG
SIb3DQEBBQUAMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAo
UHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBD
QTAeFw0wNjEwMTEwODIyMTFaFw0wNzEwMTEwODIyMTFaMGoxEDAOBgNVBAQTB1NsYWd0ZXIx
FTATBgNVBCoTDEVyaWsgTWFydGlqbjEdMBsGA1UEAxMURXJpayBNYXJ0aWpuIFNsYWd0ZXIx
IDAeBgkqhkiG9w0BCQEWEWVyaWtAc2xhZ3Rlci5uYW1lMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAzOa7QkUJm2c8W3syHePnJqqyM80fGTMcjx+KTLKzy3tS/UsG81mWz2WR
GOO7ZnhCb+CWR6OhaUrHFx4+WKZNoupfrvR673sSlWVaOmzvMxCRjVmlmxNGP+MFIbL5UMPL
LETAzWW+mEd0gAx4E7bj4Aoaow8V9Y50CvrxcZN7P7m+eZzlo80SLaj1iTbkWnOXrL+Q0keN
00JtGLo6AFz57MM69pdcuKAikIjyK3+Xq5SutDeHfVEtxD6QpAchssmEOyBO+TQeRP5AnzVf
IONW6SSAerKGwlJfn2h6M0g/3AH62IUTQo//y5BuauRLSqCkhTCkmaFZsFLL++zPxiaV2wID
AQABoy4wLDAcBgNVHREEFTATgRFlcmlrQHNsYWd0ZXIubmFtZTAMBgNVHRMBAf8EAjAAMA0G
CSqGSIb3DQEBBQUAA4GBADxdfrvMPvmfGqigTzfchB7frvxguXARy0xNJbQbjyg3VK+Tzi9c
qybFrBYGo9vzDwNsPnReHXGZs+wyqQpS9vtOhXV5lGu4Ts6cOB4Etq4s55SE9CrqG4Q48Y/V
f1tXcwKdjcMJbLiM+tP7dsPe2+ZojMJTYqDavQqFziIksSNhMIIDPzCCAqigAwIBAgIBDTAN
BgkqhkiG9w0BAQUFADCB0TELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTES
MBAGA1UEBxMJQ2FwZSBUb3duMRowGAYDVQQKExFUaGF3dGUgQ29uc3VsdGluZzEoMCYGA1UE
CxMfQ2VydGlmaWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjEkMCIGA1UEAxMbVGhhd3RlIFBl
cnNvbmFsIEZyZWVtYWlsIENBMSswKQYJKoZIhvcNAQkBFhxwZXJzb25hbC1mcmVlbWFpbEB0
aGF3dGUuY29tMB4XDTAzMDcxNzAwMDAwMFoXDTEzMDcxNjIzNTk1OVowYjELMAkGA1UEBhMC
WkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1Ro
YXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMIGfMA0GCSqGSIb3DQEBAQUAA4GN
ADCBiQKBgQDEpjxVc1X7TrnKmVoeaMB1BHCd3+n/ox7svc31W/Iadr1/DDph8r9RzgHU5VAK
MNcCY1osiRVwjt3J8CuFWqo/cVbLrzwLB+fxH5E2JCoTzyvV84J3PQO+K/67GD4Hv0CAAmTX
p6a7n2XRxSpUhQ9IBH+nttE8YQRAHmQZcmC3+wIDAQABo4GUMIGRMBIGA1UdEwEB/wQIMAYB
Af8CAQAwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC50aGF3dGUuY29tL1RoYXd0ZVBl
cnNvbmFsRnJlZW1haWxDQS5jcmwwCwYDVR0PBAQDAgEGMCkGA1UdEQQiMCCkHjAcMRowGAYD
VQQDExFQcml2YXRlTGFiZWwyLTEzODANBgkqhkiG9w0BAQUFAAOBgQBIjNFQg+oLLswNo2as
Zw9/r6y+whehQ5aUnX9MIbj4Nh+qLZ82L8D0HFAgk3A8/a3hYWLD2ToZfoSxmRsAxRoLgnSe
JVCUYsfbJ3FXJY3dqZw5jowgT2Vfldr394fWxghOrvbqNOUQGls1TXfjViF4gtwhGTXeJLHT
HUb/XV9lTzGCA2QwggNgAgEBMHYwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBD
b25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFp
bCBJc3N1aW5nIENBAhB+/ozDJCC73zBs4/jpNZ8PMAkGBSsOAwIaBQCgggHDMBgGCSqGSIb3
DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA3MDgwNDE2MjQwNlowIwYJKoZI
hvcNAQkEMRYEFGPCC2e/vnDuoMX3EOeZ32/jt1h+MFIGCSqGSIb3DQEJDzFFMEMwCgYIKoZI
hvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3
DQMCAgEoMIGFBgkrBgEEAYI3EAQxeDB2MGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3
dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJl
ZW1haWwgSXNzdWluZyBDQQIQfv6MwyQgu98wbOP46TWfDzCBhwYLKoZIhvcNAQkQAgsxeKB2
MGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQu
MSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIQfv6MwyQg
u98wbOP46TWfDzANBgkqhkiG9w0BAQEFAASCAQAvWN3B3f2YUj3XEfmyeJAaZBhnmG+Y0gqh
4GB3xI7K80YDJGoqO5kHrpCZOyLQyRhLbxcA0vNEweiaSvI6aICS6Cw3I39kD8sj7xKq6SU3
62dGbsHosi+vHtLL/Q9UkHnsuRHyT3HMavUBVikT6LG6hWzaUyQ8DFbtxcxm6KsxjoPg0OLZ
cSXLCZHXGmg891FTjMBK8nYGY46rmpu9p3j8GEae4vIpZR1S5MKoNcsdRzAbME9vUkIlztQn
Xb0DlXYXu+hsbjh4rMrBQFTl8sibSdpWxz/sFNU7iSV1irQvZzkFc2c+QyoBiyJU/XdOkWMg
ANucR53D93WG2Pbpx1eVAAAAAAAA
--------------ms020805010300020608050602--
