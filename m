From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge device
Date: Tue, 2 Sep 2003 19:32:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309021932.37224.bdschuym@pandora.be>
References: <200308301504.03241.bdschuym@pandora.be> <20030830203043.0eb1a660.davem@redhat.com> <20030902082807.0e18fe76.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030902082807.0e18fe76.shemminger@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 02 September 2003 17:28, Stephen Hemminger wrote:
> Bridge of a VLAN makes sense and is done.
> VLAN of a bridge might be done by someone for redundancy or testing.
>
> Don't apply the patch, can't see the harm in allowing either case.

OK. But isn't br0.15 supposed to work like this: all vlan tagged traffic with 
tag different from 15 is discarded, all non-tagged traffic is given to br0. 
This is how it works with a vlan on top of physical devices like eth0 if I 
read the code correctly, but it doesn't currently work like that for vlan on 
top of a logical bridge device. The vlan code only sees tagged packets if the 
packets are destined for the bridge box itself, so bridged traffic is 
unaffected.
This is why I think a vlan device on top of br0 in Linux is currently useless.

cheers,
Bart
