From: Paul Mackerras <paulus@samba.org>
Subject: Re: GigE on PowerMac G5
Date: Sun, 5 Mar 2006 10:36:18 +1100
Message-ID: <17418.9330.763002.180595@cargo.ozlabs.ibm.com>
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

Andreas Schwab writes:

> I suppose the NIC in the PowerMac G5 can do GigE, yet when plugged into a
> GB switch it is only willing to talk 100MB with it.  Any idea why?  Kernel
> is 2.6.16-rc5-git2.

It does 1000Mb/s here...

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Advertised auto-negotiation: No
        Speed: 1000Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 0
        Transceiver: external
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x00000007 (7)
        Link detected: yes

Paul.
