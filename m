From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge device
Date: 30 Aug 2003 23:16:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3ad9qx2wf.fsf@defiant.pm.waw.pl>
References: <200308301504.03241.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S.Miller" <davem@redhat.com>,
   Stephen Hemminger <shemminger@osdl.org>,
   Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200308301504.03241.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart De Schuymer <bdschuym@pandora.be> writes:

> The patch below disables making vlan devices on top of bridge
> devices, f.e. br0.12 would be impossible.
> I'm no vlan expert, but I don't see the use for this

There could be some - I'm not using such setup, but I can imagine
doing trunk bridging.
This is sometimes used with dumb (non-VLAN but 1518 bytes-capable)
switches. With Linux, it might be used as well, especially if someone
wants STP to manage trunks and not VLANs (with many VLANs it may
make perfect sense)
-- 
Krzysztof Halasa, B*FH
