From: James Morris <jmorris@redhat.com>
Subject: Re: Oops in __xfrm4_state_lookup when setting up an IPSEC tunnel
Date: Tue, 4 Nov 2003 23:12:30 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0311042304070.12463-100000@thoron.boston.redhat.com>
References: <3FA8245B.8030302@davehollis.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David T Hollis <dhollis@davehollis.com>
In-Reply-To: <3FA8245B.8030302@davehollis.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Nov 2003, David T Hollis wrote:

> Both firewalls are RedHat 9 based installs, running stock 2.6.0-test9 
> kernels (note the variance on bk7 and bk9).  Both are running Shorewall 
> 1.4.7c to setup iptables/netfilter firewalling.

Nothing obvious has changed between these snapshots which would 
cause this.  Are the filtering rules the same at each gateway?

Are you able to reproduce the problem without any filtering rules?

> 
> If I configure the SAD and SPDs on gw2, than setup them up on gw1, gw2 
> Oops hard on __xfrm4_state_lookup.  I have not yet hand copied the 
> entire dump but have the initial pertinent
> info:
> 
> EIP is at __xfrm4_state_lookup+0x6f/0xa0

If you compile your kernel with -g, you should be able to find the 
corresponding line of code (e.g. with addr2line).


- James
-- 
James Morris
<jmorris@redhat.com>
