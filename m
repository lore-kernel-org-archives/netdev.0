From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Add sysctl entries for bridge-nf
Date: Wed, 24 Dec 2003 19:32:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031224193236.7ee420ff.davem@redhat.com>
References: <200312222301.47186.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312222301.47186.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 22 Dec 2003 23:01:47 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> The following patch adds these sysctl entries in /proc/sys/net/bridge/:
> bridge-nf-call-arptables - pass or don't pass bridged ARP traffic to
> arptables' FORWARD chain.
> bridge-nf-call-iptables - pass or don't pass bridged IPv4 traffic to
> iptables' chains.
> bridge-nf-filter-vlan-tagged - pass or don't pass bridged vlan-tagged
> ARP/IP traffic to arptables/iptables.
> 
> It adds the necessary constants to sysctl.h, changes br_netfilter.c and
> adds some info to the ip-sysctl documentation.
> The default values are so that the old behavior is kept by default.

Applied, thanks Bart.
