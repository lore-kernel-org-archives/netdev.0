From: Bob Wirka <bobwirka@rtcworks.com>
Subject: Re: NFS and Network Driver Question
Date: Tue, 19 Oct 2004 19:19:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4175AEFE.7090002@rtcworks.com>
References: <41704198.8000206@rtcworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <41704198.8000206@rtcworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ok, now I feel like I'm taking crazy pills...

The embedded system boots up and mounts the root file system on my host 
laptop. The 'rc.sysinit' startup script executes the command 'mount -a' 
which should mount /proc, /dev/pts, and /dev/shm, as listed in 
/etc/fstab. When executed, that command returns  "mount: only root can 
do that".

When I get to the bash prompt, 'whoami' reports that I am, indeed, root. 
A 'mount -a' from the command prompt gives the same result; it doesn't 
think I'm root for the mount command.

I can chown a file owned by root to some other user, and I can create a 
file or directory in a directory owned by root; so it doesn't always 
think I'm not root.

Any ideas???

Thanks,

Bob Wirka
Realtime Control Works

Bob Wirka wrote:

> Hello,
>
> I'm trying to build a kernel that mounts a NFS root file system. This 
> is an embedded system; it uses an SMSC LAN91C111 network chip that is 
> hardwired to I/O addres 0x300 and IRQ 5. I've been using the driver 
> (as supplied by SMSC) as a module, and it works fine. Now I'm trying 
> to incorporate it into the kernel build so that I can mount an NFS 
> file system when the system boots.
>
> I've added the source code to the kernel tree, and modified the 
> Makefile(s) and Config.in files so that the driver <<appears>> to be 
> compiled into the kernel. The kernel will load, but the chip is not 
> initialized and the NFS fails.
>
> Since I don't know how to pass the io address and irq number to the 
> kernel, I've hard-coded them into the driver's init function (which I 
> don't see being called).
>
> If someone could point me in the right direction, I'd appreciate it.
>
> Thank you,
>
> Bob Wirka
> Realtime Control Works
>
>
