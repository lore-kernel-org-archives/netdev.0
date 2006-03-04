From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: GigE on PowerMac G5
Date: Sun, 05 Mar 2006 08:16:40 +1100
Message-ID: <1141507000.17127.4.camel@localhost.localdomain>
References: <jebqwmfeh9.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc64-dev@ozlabs.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Andreas Schwab <schwab@suse.de>
In-Reply-To: <jebqwmfeh9.fsf@sykes.suse.de>
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

On Sat, 2006-03-04 at 15:53 +0100, Andreas Schwab wrote:
> [Sorry for duplicate posting, I've used the wrong list address.]
> 
> I suppose the NIC in the PowerMac G5 can do GigE, yet when plugged into a
> GB switch it is only willing to talk 100MB with it.  Any idea why?  Kernel
> is 2.6.16-rc5-git2.

Works for me... Must be a problem with auto-neg and your switch, or the
cable.... Can you check how the switch is configured maybe ? You can
also try forcing the link speed with ethtool.

Ben.
 
> # lsprop /proc/device-tree/ht@0,f2000000/pci@6/ethernet@f
> name             "ethernet"
> linux,phandle    ff9c53d8
> interrupt-parent ff9779b0
> gbit-phy        
> assigned-addresses 82047810 00000000 80400000 00000000 00200000
>                  82047830 00000000 80300000 00000000 00100000
> local-mac-address 00 0a 95 ba b8 70                              .....p
> stats            00000000 00000000 00000000 00000000 00000000
> reg              00047800 00000000 00000000 00000000 00000000
>                  02047810 00000000 00000000 00000000 00020000
>                  02047830 00000000 00000000 00000000 00010000
> max-frame-size   000005ee (1518)
> address-bits     00000030 (48)
> built-in        
> compatible       "K2-GMAC"
> category         "net"
> removable        "network"
> network-type     "ethernet"
> device_type      "network"
> fast-back-to-back
> devsel-speed     00000002
> max-latency      00000040 (64)
> min-grant        00000040 (64)
> interrupts       00000029 00000001
> class-code       00020000 (131072)
> revision-id      00000000
> device-id        0000004c (76)
> vendor-id        0000106b (4203)
> # ethtool eth0
> Settings for eth0:
>         Supported ports: [ TP MII ]
>         Supported link modes:   10baseT/Half 10baseT/Full 
>                                 100baseT/Half 100baseT/Full 
>                                 1000baseT/Half 1000baseT/Full 
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full 
>                                 100baseT/Half 100baseT/Full 
>                                 1000baseT/Half 1000baseT/Full 
>         Advertised auto-negotiation: No
>         Speed: 100Mb/s
>         Duplex: Full
>         Port: MII
>         PHYAD: 0
>         Transceiver: external
>         Auto-negotiation: on
>         Supports Wake-on: g
>         Wake-on: d
>         Current message level: 0x00000007 (7)
>         Link detected: yes
> 
> Andreas.
> 
