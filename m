From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Fri, 25 Jul 2003 21:23:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307252123460606.0555F082@192.168.128.16>
References: <200307241728270476.0031BAB0@192.168.128.16>
 <Pine.LNX.4.44.0307241849341.2177-100000@l>
 <20030724091007.68923845.davem@redhat.com>
 <200307252024190066.051F80CE@192.168.128.16>
 <20030725114634.73dc9e8d.davem@redhat.com>
 <200307252036050292.052A4780@192.168.128.16>
 <20030725115902.1d2f61b2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: ja@ssi.bg, bdschuym@pandora.be, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030725115902.1d2f61b2.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 25/07/2003 at 11:59 David S. Miller wrote:

>I'm talking about a netfilter module, and yes it does require
>a tool for configuration which Bart DeSchuym has written, he
>posted a link to his work earlier in these threads.

Well, I consider the hiding patch to be a simplier and better approach to this strange behaviour in Linux (compared to other OS and systems) than needing to include and compile netfilter in the kernel. However I will take a look at it.

I have searched and found that this is not the first time that this discussion has raised:

http://www.ussg.iu.edu/hypermail/linux/kernel/0212.0/1128.html

Really I am 100% in accordance with this:

===
I still don't see why an address that is 
-=ASSIGNED TO AN INTERFACE=- should be responded to on a completely 
different interface... if we wanted the ip address to be assigned to the 
system, there should be a pseudo interface that will work on any of the 
interfaces attached. Why assign an address to an interface if it would work 
just the same if you assigned it to the loopback adapter? Why would you 
assign an address to the loopback adapter if you wanted it to be accessed 
from the world? 
===

Is "hiding" incompatible with any other feature?

Regards,
Carlos Velasco
