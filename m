From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [BUG] open network driver bugs (100)
Date: Mon, 3 Dec 2007 17:52:34 -0800
Message-ID: <20071203175234.0049330b@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42823 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975AbXLDBx6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 20:53:58 -0500
Received: from freepuppy.rosehill (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id lB41rtdf002695
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 3 Dec 2007 17:53:57 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ID 	Assignee 			Summary=20
2283 	c-d.hailfinger.kernel.2004@... 	(net forcedeth) NETDEV WATCHDOG: =
eth1: transmit timed out...=20
2776 	grundler@parisc-linux.org 	(net dmfe) Davicom 9102AF only works i=
n 10 Mbps=20
3156 	grundler@parisc-linux.org 	(net de2104x) Kernel panic with de2104=
x tulip driver on boot=20
3526 	jgarzik@pobox.com 	(net 8139too) CardBus NIC locks up system with=
 PIO=20
3661 	jgarzik@pobox.com 	(net 8139too) gives strange errors, drops and =
overruns in...=20
3765 	jgarzik@pobox.com 	(net b44) Network link down, when writting to =
sata disk A...=20
3801 	jgarzik@pobox.com 	(net 8139too) does not set PME-Enable upon set=
ting WOL=20
3938 	jgarzik@pobox.com 	(net tun) device driver doesn't fill in interf=
ace name on...=20
4186 	linville@tuxdriver.com 	(wireless airo) Aironet 340 PCMCIA does n=
ot support WPA=20
4420 	grundler@parisc-linux.org 	(net tulip) Problem with 6 bit address=
ing in tulip_read_e...=20
4434 	grundler@parisc-linux.org 	(net Tulip) NIC card causes hard lock =
up of PC=20
4451 	rl@hellgate.ch 	(net via-rhine) VIA Rhine II: media detection fai=
ls on re...=20
4566 	jgarzik@pobox.com 	(net B44) Randomly driver starts sending garba=
ge and stop...=20
4701 	grundler@parisc-linux.org 	(net tulip) No driver works with Asant=
=C3=AF=C2=BF=C2=BDFAST 10/100 PWA ...=20
4755 	jgarzik@pobox.com 	(net b44) At system startup b44 doesn't report=
 correct mi...=20
4849 	rl@hellgate.ch 	(net via-rhine) WAKE ON LAN not working.=20
4883 	jgarzik@pobox.com 	(net tg3) doesn't send ARP reply on 8021q VLAN=
 interfaces=20
5149 	auke-jan.h.kok@intel.com 	Wake-on-lan broken using Intel e100 dri=
ver=20
5569 	jgarzik@pobox.com 	(net xirc2ps_cs) stopped working in 2.6.14=20
5624 	jgarzik@pobox.com 	(net b44) Lockup on 'mii-tool ethX' when 'ifco=
nfig ethX u...=20
5839 	grundler@parisc-linux.org 	uli526x partially recognizing interfac=
e=20
5870 	romieu@fr.zoreil.com 	SiS 190 doesn't download files=20
5979 	jgarzik@pobox.com 	(net dmfe) Davicom DM9102 Network Card cuts ou=
t every 60 ...=20
6108 	romieu@fr.zoreil.com 	Failure of r8169 ethernet i/f after resume =
from S3 sleep=20
6171 	acme@ghostprotocols.net 	3c59x: netlink only updates online statu=
s each 60s=20
6444 	klassert@mathematik.tu-chem... 	(net 3c59x) transmit timed out=20
6690 	aabdulla@nvidia.com 	(net forcedeth) 0.57 problems at gigabit spe=
eds=20
6807 	romieu@fr.zoreil.com 	r8169: freeze at higher speeds=20
6986 	auke-jan.h.kok@intel.com 	e1000 doesn't update trafic counters fr=
equently enough=20
7051 	linville@tuxdriver.com 	prism54 does not respect carrier=20
7071 	jgarzik@pobox.com 	(net cassini) Can't bring Sun Quad GigaSwift E=
thernet int...=20
7085 	romieu@fr.zoreil.com 	System freezes when load the module sis190=20
7133 	jgarzik@pobox.com 	(net ibmtr_cs) seams working as fine with 64bi=
t kernel th...=20
7226 	jgarzik@pobox.com 	(net 8139too) Problem in forcing RTL8139 into =
100Mbps ful...=20
7440 	klassert@mathematik.tu-chem... 	(net 3c59x) suddenly receives no =
more packets=20
7443 	jgarzik@pobox.com 	(net 8139too) transmit timeouts with edge trig=
gered PCI irq=20
7487 	jgarzik@pobox.com 	(net sundance) driver fails to recognize carri=
er status=20
7588 	jgarzik@pobox.com 	(net wan z85230) Race: Lock is not acquired be=
fore callin...=20
7617 	shemminger@linux-foundation... 	sky2 driver crashes=20
7633 	jgarzik@pobox.com 	(net bonding) Race: Caller of function alb_swa=
p_mac_addr(...=20
7659 	jgarzik@pobox.com 	(net 3c589_cs) Race: a lock must be held befor=
e entering ...=20
7660 	jgarzik@pobox.com 	(net wan z85230) Race: lock must be held befor=
e entering ...=20
7682 	Larry.Finger@lwfinger.net 	bcm43xx: iwlist scan: "no scan results=
" with 2.6.19.1=20
7696 	jgarzik@pobox.com 	(net b44) driver doesn't work under heavy load=
=20
7718 	jgarzik@pobox.com 	(net xircom_cb, xircom_tulip_cb) When card ins=
erted, dmes...=20
7752 	kune@deine-taler.de 	drivers/net/wireless/zd1211rw/zd_chip.c:1461=
 ASSERT r >=3D ...=20
7821 	romieu@fr.zoreil.com 	sundance driver not activating D-Link DFE-5=
80TX adapter=20
7853 	paulus@samba.org 	(net ppp) Get "mppe_decompress: osize too small=
" while fo...=20
7856 	jgarzik@pobox.com 	(net b44) WOL problem=20
7946 	yi.zhu@intel.com 	ipw2200 driver + wpa_supplicant (wpa-psk) =3D f=
ail to send ...=20
8007 	klassert@mathematik.tu-chem... 	(net 3c59x) 3c905 Tornado dosen't=
 work (eeprom mac addres...=20
8009 	paulus@samba.org 	(net ppp) PPPoE+mppe Server fail with Win Clien=
t=20
8043 	jesse.brandeburg@intel.com 	curious communication breakage with e=
1000 and NBT=20
8061 	romieu@fr.zoreil.com 	is VIA Network device statistics calculatio=
n wrong? missi...=20
8084 	jgarzik@pobox.com 	phy_mii_ioctl(...) forgets to return phy_devic=
e's speed s...=20
8106 	broonie@sirena.org.uk 	tx_errors and tx_fifo_errors not updated c=
onsistantly=20
8132 	paulus@samba.org 	pptp server lockup in ppp_asynctty_receive()=20
8252 	romieu@fr.zoreil.com 	Via Velocity "eth0: excessive work at inter=
rupt."=20
8329 	Eric.Moore@lsil.com 	mtplan.c: kmalloc while spinlock is held=20
8330 	jgarzik@pobox.com 	(net wan lmc) lmc: copy_to/from_user cals whil=
e spinlock ...=20
8381 	aabdulla@nvidia.com 	(net forcedeth) doesn't wol on suspend=20
8430 	auke-jan.h.kok@intel.com 	BUG: e1000: scheduling while atomic: mi=
i-tool=20
8443 	aabdulla@nvidia.com 	(net forcedeth) v0.56 delivers MAC-Address b=
ackwards=20
8447 	dsd@gentoo.org 	zd1211rw does not bring ethX up on some hardware =
setups=20
8525 	romieu@fr.zoreil.com 	Realtek RTL8168B does not initialize when r=
ebooting from ...=20
8568 	aabdulla@nvidia.com 	forcedeth: autonegotiation weirdness with du=
al port nforc...=20
8604 	aabdulla@nvidia.com 	Forcedeth IRQ / soft lockup=20
8612 	aabdulla@nvidia.com 	(net forcedeth) Ethernet spin down (mcp51)=20
8637 	shemminger@linux-foundation... 	skge doesn't wakeonlan (wol) whil=
st hibernated=20
8642 	aabdulla@nvidia.com 	forcedeth doesn't work on MCP61 chipset main=
board=20
8699 	mchan@broadcom.com 	(net bnx2) needs delay for VLAN tagging=20
8700 	aabdulla@nvidia.com 	(net forcedeth) Any ethernet going down=20
8733 	aabdulla@nvidia.com 	(net forcedeth) stuck in long loop on loadin=
g=20
8776 	mchan@broadcom.com 	tg3 I/O lockup after a certain number of pack=
ets=20
8780 	mchan@broadcom.com 	tg3 crashing=20
8808 	jgarzik@pobox.com 	(net b44) Large file transfer causes kernel pa=
nic showing...=20
8930 	linville@tuxdriver.com 	duplicate forward declaration of void hos=
tap_80211_rx in ...=20
8952 	grundler@parisc-linux.org 	tulip driver oops in tulip_interrupt w=
hen hibernating wit...=20
8962 	shemminger@linux-foundation... 	sky2: network intermittently unav=
ailable after ifdown/ifu...=20
8972 	dsd@gentoo.org 	zd1211 device is no longer configured=20
8991 	samuel@sortiz.org 	(IrDA) nsc-ircc not working anymore since 2.6.=
22.5=20
8996 	jcliburn@gmail.com 	atl1 driver cause kernel oops IF ram > 4Gyte =
and a lot of...=20
9015 	aabdulla@nvidia.com 	network load can break nforce nic (forcedeth=
 driver)=20
9047 	aabdulla@nvidia.com 	(net forcedeth) MCP55 oops under heavy load=20
9094 	grundler@parisc-linux.org 	dmfe driver stopped working correctly =
in kernel 2.6.22=20
9106 	grundler@parisc-linux.org 	Sun Fire v100 dmfe driver bug=20
9200 	aabdulla@nvidia.com 	(net forcedeth) frequent network ups and dow=
ns=20
9225 	jgarzik@pobox.com 	(net typhoon) "no descs for cmd, had (needed) =
0 (1) cmd, ...=20
9234 	mb@bu3sch.de 	Crash after ifconfig down on b43 driver=20
9269 	jgarzik@pobox.com 	(net sunhme) cannot enslave ethernet devices=20
9270 	jgarzik@pobox.com 	(net sunhme) requires lower MTU to handle 802.=
1q frames=20
9311 	jgarzik@pobox.com 	sundance -> 4port D-Link System Inc DFE-580TX =
-> Log errors=20
9317 	jgarzik@pobox.com 	Oops in via-rhine=20
9336 	jgarzik@pobox.com 	e100 does not work after boot=20
9380 	shemminger@linux-foundation... 	skge: dual port board sometimes l=
ocks up=20
9386 	romieu@fr.zoreil.com 	sis190 network driver crash=20
9388 	IvDoorn@gmail.com 	Unable to associate rt25xx USB key with a WPA =
AP=20
9391 	mchan@broadcom.com 	Netgear GA320T(tg3) strange errors and non-wo=
rkingness=20
9468 	romieu@fr.zoreil.com 	r8169, swiotlb, 4GB RAM, breakage=20
9470 	drivers_network-wireless@ke... 	Oops with 2.6.24 git when loading=
 iwl3945
