From: Bob Wirka <bobwirka@rtcworks.com>
Subject: NFS and Network Driver Question
Date: Fri, 15 Oct 2004 16:31:04 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41704198.8000206@rtcworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I'm trying to build a kernel that mounts a NFS root file system. This is 
an embedded system; it uses an SMSC LAN91C111 network chip that is 
hardwired to I/O addres 0x300 and IRQ 5. I've been using the driver (as 
supplied by SMSC) as a module, and it works fine. Now I'm trying to 
incorporate it into the kernel build so that I can mount an NFS file 
system when the system boots.

I've added the source code to the kernel tree, and modified the 
Makefile(s) and Config.in files so that the driver <<appears>> to be 
compiled into the kernel. The kernel will load, but the chip is not 
initialized and the NFS fails.

Since I don't know how to pass the io address and irq number to the 
kernel, I've hard-coded them into the driver's init function (which I 
don't see being called).

If someone could point me in the right direction, I'd appreciate it.

Thank you,

Bob Wirka
Realtime Control Works
