From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [PATCH 2.5.69] Bridge timer performance enhancement
Date: Wed, 14 May 2003 07:29:20 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514072350.P23367@shell.cyberus.ca>
References: <20030509132012.598602ec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   bridge@math.leidenuniv.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030509132012.598602ec.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Stephen,
Seems you are the new maintainer to the bridging code? I suppose Lennert
is still still listening in the background somewhere. One thing we should
do post 2.6 is move all the STP protocol specific out of the kernel.
i.e leave the datapath controllers (such as controlling STP states)
in the kernel but have a user sapce daemon. This way you can start adding
a lot more feature rich extensions in user space without waiting for
kernel releases or having kernel patches (Fast Forward etc).
A second item is to start looking at integrating STP with the VLAN code.
Too bad Lennert (and someone else - cant remember the name) VLAN code
never made it in. We can  still fix this.

cheers,
jamal
