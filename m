From: Simon Roscic <simon.roscic@chello.at>
Subject: Fwd: [2.6] ethertap and af_inet.c assertion failures
Date: Fri, 24 Dec 2004 00:02:13 +0100
Message-ID: <200412240002.13206.simon.roscic@chello.at>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(i forgot to cc this mail to this list, sorry)

----------  Forwarded Message  ----------

Subject: [2.6] ethertap and af_inet.c assertion failures
Date: Wednesday 22 December 2004 19:53
From: Simon Roscic <simon.roscic@chello.at>
To: linux-kernel@vger.kernel.org

(please cc me, as i'm not subscribed to lkml - thanks)

hi,

today i upgraded my kernel from 2.6.9-rc2 to 2.6.10-rc3-bk12, now i get the
following assertion failures while using the (closed source) phion vpn
client, the vpn client uses ethertap, there are no closed source kernel
modules or the like:

KERNEL: assertion (!atomic_read(&sk->sk_wmem_alloc)) failed at
net/ipv4/af_inet.c (150)

when the kernel prints out the above message the connection for the program
using the vpn gets stuck - it happens very often if i use rdesktop, but it
also happens when i just use ssh, so the bug may be triggered more often when
there is more traffic over the vpn tunnel.

i tried with some other 2.6 kernel releases:

up to and including 2.6.9-rc2: no problem
2.6.9-rc3      does not boot on my machine
2.6.9-rc4      assertion failed as explained above
2.6.9        assertion failed as explained above

so it seems ethertap got broken somewhere post 2.6.9-rc2.
any ideas what got changed post 2.6.9-rc2 wich might cause this?

thanks for looking at this problem, if i can provide more information, just
contact me.

bye,
 simon.

-------------------------------------------------------
