From: Dax Kelson <dax@gurulabs.com>
Subject: Re: [BUG] can't unload network device's if IPV6 is loaded
Date: Sun, 14 Dec 2003 22:51:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1071467514.3219.11.camel@mentor.gurulabs.com>
References: <20031211153334.0c59214b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031211153334.0c59214b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-12-11 at 16:33, Stephen Hemminger wrote:
> In 2.6.0-test11, IPV6 is not correctly cleaning up the network device reference's
> (ie missing dev_put).  So if I do:
> 	rmmod e100
> it hangs forever and complains about that not all references have been cleaned up.
> 
> This happens even if no IPV6 addresses have been set up. Just having ipv6 available
> to be loaded at boot up.  The vendor startup scripts (SuSe 9) may be setting something.

I noticed this on my laptop with my internal Dell TrueMobile 1150
wireless 802.11 card (orinoco_cs).

On my Fedora box when I added IPV6=yes to /etc/sysconfig/network I
couldn't get clean reboots or shutdowns.

Dax Kelson
Guru Labs
