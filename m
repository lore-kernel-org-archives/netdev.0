From: VinX <vincenx@fastwebnet.it>
Subject: tiacx module fail
Date: Sun, 10 Sep 2006 13:25:52 +0200
Message-ID: <4503F640.3040300@fastwebnet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa002msr.fastwebnet.it ([85.18.95.65]:38790 "EHLO
	aa002msr.fastwebnet.it") by vger.kernel.org with ESMTP
	id S1750734AbWIJLG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 07:06:57 -0400
Received: from theconfessional.redirectme.net (23.251.157.101) by aa002msr.fastwebnet.it (7.2.070.1)
        id 44ECD14E00916934 for netdev@vger.kernel.org; Sun, 10 Sep 2006 13:06:53 +0200
Received: from [192.168.1.144] (unknown [192.168.0.50])
	by theconfessional.redirectme.net (Postfix) with ESMTP id 791AF38E663
	for <netdev@vger.kernel.org>; Sun, 10 Sep 2006 13:03:41 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
i have a little problem with dlink dwl650+ pcmcia.
After I downloaded wireless-2.6.git with cogito, compiled, rebooted my
laptop and loaded the acx_pci module. But my pcmcia don't work.
If i give this command line:
# iwlist scanning
eth1     Interface doesn't support scanning : Resource temporarily
unavailable
I tried with a 2.6.18-rc5 with tiacx and 2.6.17.13 with acx module, same
result.
The dmesg with tiacx module is:
--
Sep  9 19:19:37 vinTux acx: compiled to use 32bit I/O access. I/O timing
issues might occur, such as non-working fir
mware upload. Report them
Sep  9 19:19:37 vinTux running on a little-endian CPU
Sep  9 19:19:37 vinTux PCI module v0.4.7 initialized, waiting for cards
to probe...
Sep  9 19:19:37 vinTux PCI: Enabling device 0000:02:00.0 (0000 -> 0003)
Sep  9 19:19:37 vinTux ACPI: PCI Interrupt 0000:02:00.0[A] -> Link
[LNKA] -> GSI 11 (level, low) -> IRQ 11
Sep  9 19:19:37 vinTux PCI: Setting latency timer of device 0000:02:00.0
to 64
Sep  9 19:19:37 vinTux acx: found ACX100-based wireless network card at
0000:02:00.0, irq:11, phymem1:0x42010000, ph
ymem2:0x42000000, mem1:0xfc994000, mem1_size:4096, mem2:0xfc9e0000,
mem2_size:65536
Sep  9 19:19:37 vinTux initial debug setting is 0x000A
Sep  9 19:19:37 vinTux using IRQ 11
Sep  9 19:19:37 vinTux requesting firmware image 'tiacx100c0D'
Sep  9 19:19:37 vinTux acx: firmware image 'tiacx100c0D' was not
provided. Check your hotplug scripts
Sep  9 19:19:37 vinTux requesting firmware image 'tiacx100'
Sep  9 19:19:38 vinTux acx_write_fw (main/combined):0
Sep  9 19:19:38 vinTux acx_validate_fw (main/combined):0
Sep  9 19:19:38 vinTux acx100_s_init_wep: writing WEP options
Sep  9 19:19:38 vinTux initializing max packet templates
Sep  9 19:19:38 vinTux unknown chip and EEPROM version combination
(ACX100, v0), don't know how to parse config opti
ons yet. Please report
Sep  9 19:19:38 vinTux get_mask 0x00004D82, set_mask 0x00000000
Sep  9 19:19:38 vinTux got sensitivity value 64
Sep  9 19:19:38 vinTux got antenna value 0x08
Sep  9 19:19:38 vinTux got Energy Detect (ED) threshold 112
Sep  9 19:19:38 vinTux got Channel Clear Assessment (CCA) value 13
Sep  9 19:19:38 vinTux got regulatory domain 0x30
Sep  9 19:19:38 vinTux get_mask 0x00000000, set_mask 0x00000000 - after
update
Sep  9 19:19:38 vinTux new ratevector: 82 84 0B 16 2C
Sep  9 19:19:38 vinTux setting RXconfig to 2010:0FDD
Sep  9 19:19:38 vinTux acx: form factor 0x01 ((mini-)PCI / CardBus),
radio type 0x0D (Maxim), EEPROM version 0x00, u
ploaded firmware 'Rev 1.9.10.0_A4' (0x01030505)
Sep  9 19:19:38 vinTux creating /proc entry driver/acx_eth1
Sep  9 19:19:38 vinTux creating /proc entry driver/acx_eth1_diag
Sep  9 19:19:38 vinTux creating /proc entry driver/acx_eth1_eeprom
Sep  9 19:19:38 vinTux creating /proc entry driver/acx_eth1_phy
Sep  9 19:19:38 vinTux acx v0.4.7: net device eth1, driver compiled
against wireless extensions 20
Sep  9 19:19:39 vinTux acx_set_status(1):SCANNING
Sep  9 19:19:39 vinTux updating initial settings on iface activation
Sep  9 19:19:39 vinTux get_mask 0x00000000, set_mask 0x0036EEFC
Sep  9 19:19:39 vinTux important setting has been changed. Need to
update packet templates, too
Sep  9 19:19:39 vinTux updating packet templates
Sep  9 19:19:39 vinTux updating Tx fallback to 1 retries
Sep  9 19:19:39 vinTux updating transmit power: 18 dBm
Sep  9 19:19:39 vinTux updating antenna value: 0x08
Sep  9 19:19:39 vinTux updating Energy Detect (ED) threshold: 112
Sep  9 19:19:39 vinTux updating Channel Clear Assessment (CCA) value: 0x0D
Sep  9 19:19:39 vinTux updating channel to: 1
Sep  9 19:19:39 vinTux updating: enable Tx
Sep  9 19:19:39 vinTux updating: enable Rx on channel: 1
Sep  9 19:19:39 vinTux updating short retry limit: 7, long retry limit: 4
Sep  9 19:19:39 vinTux updating tx MSDU lifetime: 4096
Sep  9 19:19:39 vinTux updating regulatory domain: 0x30
Sep  9 19:19:39 vinTux setting RXconfig to 2010:0FDD
Sep  9 19:19:39 vinTux updating WEP key settings
Sep  9 19:19:39 vinTux setting WEP key 0 as default
Sep  9 19:19:39 vinTux acx_set_status(1):SCANNING
Sep  9 19:19:39 vinTux starting radio scan
Sep  9 19:19:39 vinTux get_mask 0x00000000, set_mask 0x00000000 - after
update
Sep  9 19:19:39 vinTux get_mask 0x00000000, set_mask 0x00000040
Sep  9 19:19:39 vinTux setting RXconfig to 2010:0FDD
Sep  9 19:19:39 vinTux get_mask 0x00000000, set_mask 0x00000000 - after
update
Sep  9 19:19:39 vinTux get_mask 0x00000000, set_mask 0x00000040
Sep  9 19:19:39 vinTux setting RXconfig to 2010:0FDD
Sep  9 19:19:39 vinTux get_mask 0x00000000, set_mask 0x00000000 - after
update
Sep  9 19:19:40 vinTux acx_i_timer: adev->status=1 (SCANNING)
Sep  9 19:19:40 vinTux continuing scan (1 sec)
Sep  9 19:19:40 vinTux no matching station found in range yet
Sep  9 19:19:40 vinTux acx_set_status(1):SCANNING
Sep  9 19:19:40 vinTux starting radio scan
Sep  9 19:19:41 vinTux rc-scripts:   no access points found
Sep  9 19:19:41 vinTux rc-scripts: Couldn't find any access points on eth1
Sep  9 19:19:41 vinTux rc-scripts: Failed to configure wireless for eth1
Sep  9 19:19:41 vinTux get_mask 0x00000000, set_mask 0x00000250
Sep  9 19:19:41 vinTux updating transmit power: 0 dBm
Sep  9 19:19:41 vinTux updating: disable Tx
Sep  9 19:19:41 vinTux setting RXconfig to 2010:0FDD
Sep  9 19:19:41 vinTux get_mask 0x00000000, set_mask 0x00000000 - after
update
Sep  9 19:19:41 vinTux acx_set_status(0):STOPPED
Sep  9 19:19:41 vinTux closed device
---
and the dmesg with acx module is:
---
acx: this driver is still EXPERIMENTAL
acx: reading README file and/or Craig's HOWTO is recommended, visit
http://acx100.sf.net in case of further questions/discussion
acx: compiled to use 32bit I/O access. I/O timing issues might occur,
such as non-working firmware upload. Report them
running on a little-endian CPU
PCI module v0.3.35 initialized, waiting for cards to probe...
ACPI: PCI Interrupt 0000:02:00.0[A] -> Link [LNKA] -> GSI 11 (level,
low) -> IRQ 11
acx: found ACX100-based wireless network card at 0000:02:00.0, irq:11,
phymem1:0x42010000, phymem2:0x42000000, mem1:0xb8966000, mem1_size:4096,
mem2:0xb8980000, mem2_size:65536
initial debug setting is 0x000A
using IRQ 11
requesting firmware image 'tiacx100c0D'
acx: firmware image 'tiacx100c0D' was not provided. Check your hotplug
scripts
requesting firmware image 'tiacx100'
acx_write_fw (main/combined):0
acx_validate_fw (main/combined):0
requesting firmware image 'tiacx100r0D'
acx_write_fw (radio): 0
acx_validate_fw (radio): 0
acx100_s_init_wep: writing WEP options
initializing max packet templates
NVS_vendor_offs:0000 probe_delay:500 eof_memory:65536
CCAModes:04 Diversity:01 ShortPreOpt:01 PBCC:01 ChanAgil:00 PHY:05 Temp:01
AntennaID:00 Len:02 Data:01 02
PowerLevelID:01 Len:02 Data:001E 000A
DataRatesID:02 Len:05 Data:02 04 11 22 44
DomainID:03 Len:06 Data:30 20 30 31 32 41
ProductID:04 Len:09 Data:TI ACX100
ManufacturerID:05 Len:07 Data:TI Test
get_mask 0x00004D82, set_mask 0x00000000
got sensitivity value 176
got antenna value 0x8D
got Energy Detect (ED) threshold 112
got Channel Clear Assessment (CCA) value 13
got regulatory domain 0x30
get_mask 0x00000000, set_mask 0x00000000 - after update
new ratevector: 82 84 0B 16 2C
setting RXconfig to 2010:0FDD
acx: form factor 0x01 ((mini-)PCI / CardBus), radio type 0x0D (Maxim),
EEPROM version 0x05, uploaded firmware 'Rev 1.9.10.0_A4' (0x01030505)
creating /proc entry driver/acx_wlan0
creating /proc entry driver/acx_wlan0_diag
creating /proc entry driver/acx_wlan0_eeprom
creating /proc entry driver/acx_wlan0_phy
acx v0.3.35: net device wlan0, driver compiled against wireless
extensions 20
USB module v0.3.35 initialized, probing for devices...
usbcore: registered new driver acx_usb
acx_set_status(1):SCANNING
updating initial settings on iface activation
get_mask 0x00000000, set_mask 0x0036EEFC
important setting has been changed. Need to update packet templates, too
updating packet templates
updating Tx fallback to 1 retries
updating transmit power: 18 dBm
wlan0: changing radio power level to 18 dBm (23)
updating antenna value: 0x8D
updating Energy Detect (ED) threshold: 112
updating Channel Clear Assessment (CCA) value: 0x0D
updating channel to: 1
updating: enable Tx
updating: enable Rx on channel: 1
updating short retry limit: 7, long retry limit: 4
updating tx MSDU lifetime: 4096
updating regulatory domain: 0x30
setting RXconfig to 2010:0FDD
updating WEP key settings
setting WEP key 0 as default
acx_set_status(1):SCANNING
starting radio scan
get_mask 0x00000000, set_mask 0x00000000 - after update
get_mask 0x00000000, set_mask 0x00000040
setting RXconfig to 2010:0FDD
get_mask 0x00000000, set_mask 0x00000000 - after update
get_mask 0x00000000, set_mask 0x00000040
setting RXconfig to 2010:0FDD
get_mask 0x00000000, set_mask 0x00000000 - after update
get_mask 0x00000000, set_mask 0x00000200
updating transmit power: 18 dBm
wlan0: changing radio power level to 18 dBm (23)
get_mask 0x00000000, set_mask 0x00000000 - after update
new ratevector: 82 84 8B 96 2C
get_mask 0x00000000, set_mask 0x00200004
updating packet templates
updating Tx fallback to 1 retries
get_mask 0x00000000, set_mask 0x00000000 - after update
get_mask 0x00000000, set_mask 0x00010000
important setting has been changed. Need to update packet templates, too
updating packet templates
acx_set_status(1):SCANNING
start_scan: seems like previous scan is still running. Not starting
anew. Please report
get_mask 0x00000000, set_mask 0x00000000 - after update
acx_i_timer: adev->status=1 (SCANNING)
continuing scan (1 sec)
start_scan: seems like previous scan is still running. Not starting
anew. Please report
no matching station found in range yet
acx_set_status(1):SCANNING
starting radio scan
get_mask 0x00000000, set_mask 0x00000200
updating transmit power: 18 dBm
wlan0: changing radio power level to 18 dBm (23)
get_mask 0x00000000, set_mask 0x00000000 - after update
new ratevector: 82 84 8B 96 2C
get_mask 0x00000000, set_mask 0x00200004
updating packet templates
updating Tx fallback to 1 retries
get_mask 0x00000000, set_mask 0x00000000 - after update
get_mask 0x00000000, set_mask 0x00000210
updating transmit power: 0 dBm
wlan0: changing radio power level to 0 dBm (63)
updating: disable Tx
get_mask 0x00000000, set_mask 0x00000000 - after update
get_mask 0x00000000, set_mask 0x00000040
setting RXconfig to 2010:0FDD
get_mask 0x00000000, set_mask 0x00000000 - after update
acx_set_status(0):STOPPED
closed device
---

Any idea?
Sorry for my bad english and for this long mail!

Regards
VinX

