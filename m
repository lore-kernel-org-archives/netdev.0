From: Andreas Schwab <schwab@suse.de>
Subject: GigE on PowerMac G5
Date: Sat, 04 Mar 2006 15:53:38 +0100
Message-ID: <jebqwmfeh9.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc64-dev@ozlabs.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: netdev@vger.kernel.org
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

[Sorry for duplicate posting, I've used the wrong list address.]

I suppose the NIC in the PowerMac G5 can do GigE, yet when plugged into a
GB switch it is only willing to talk 100MB with it.  Any idea why?  Kernel
is 2.6.16-rc5-git2.

# lsprop /proc/device-tree/ht@0,f2000000/pci@6/ethernet@f
name             "ethernet"
linux,phandle    ff9c53d8
interrupt-parent ff9779b0
gbit-phy        =

assigned-addresses 82047810 00000000 80400000 00000000 00200000
                 82047830 00000000 80300000 00000000 00100000
local-mac-address 00 0a 95 ba b8 70                              .....p
stats            00000000 00000000 00000000 00000000 00000000
reg              00047800 00000000 00000000 00000000 00000000
                 02047810 00000000 00000000 00000000 00020000
                 02047830 00000000 00000000 00000000 00010000
max-frame-size   000005ee (1518)
address-bits     00000030 (48)
built-in        =

compatible       "K2-GMAC"
category         "net"
removable        "network"
network-type     "ethernet"
device_type      "network"
fast-back-to-back
devsel-speed     00000002
max-latency      00000040 (64)
min-grant        00000040 (64)
interrupts       00000029 00000001
class-code       00020000 (131072)
revision-id      00000000
device-id        0000004c (76)
vendor-id        0000106b (4203)
# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full =

                                100baseT/Half 100baseT/Full =

                                1000baseT/Half 1000baseT/Full =

        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full =

                                100baseT/Half 100baseT/Full =

                                1000baseT/Half 1000baseT/Full =

        Advertised auto-negotiation: No
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 0
        Transceiver: external
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x00000007 (7)
        Link detected: yes

Andreas.

-- =

Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
