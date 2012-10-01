From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 driver upgrade (Linux 2.6.32 -> 3.2) breaks IBM
 Bladecenter SoL
Date: Mon, 1 Oct 2012 02:33:02 -0700
Message-ID: <1349083982.5420.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <87txuhho5z.fsf@lant.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Matt Carlson" <mcarlson@broadcom.com>,
	"Grant Likely" <grant.likely@secretlab.ca>,
	"Rob Herring" <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org
To: "Ferenc Wagner" <wferi@niif.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87txuhho5z.fsf@lant.ki.iif.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-09-28 at 22:45 +0200, Ferenc Wagner wrote: 
> Hi,
> 
> Upgrading the kernel on our HS20 blades resulted in their SoL (serial
> over LAN) connection being broken.  The disconnection happens when eth0
> (the interface involved in SoL) is brought up during the boot sequence.
> If I later "ip link set eth0 down", then the connection is restored, but
> "ip link set eth0 up" breaks it again on 3.2.  ethtool -a, -c, -g, -k
> and -u show no difference; ethtool -i on the 2.6.32 kernel reports:
> 
> driver: tg3
> version: 3.116
> firmware-version: 5704s-v3.38, ASFIPMIs v2.47
> bus-info: 0000:05:01.0
> 
> In the 3.2 kernel the driver version is 3.121.

2.6.32 to 3.2 is a big jump.  Can you narrow this down further?  It will
be hard for us to find a HS20 with 5704 to test this.  Thanks.
