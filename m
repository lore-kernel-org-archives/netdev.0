From: anand@eis.iisc.ernet.in (SVR Anand)
Subject: Network flood
Date: Fri, 21 Nov 2003 14:49:23 +0530 (GMT+05:30)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311210919.OAA18759@eis.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Please pardon me if I am sending this mail to an inappropriate mailing list.

I have a setup where a Linux machine (2.6-test9)intrusively sits between the 
campus netwok and a cisco router that connects to the Internet. The network 
traffic pass through one one ethernet interface, get processed more on the 
lines of a firewall, and sent out on the other interface. The packet processing
happens at the user level. I am using realtime support and enabled kernel
preemption flag for the kernel image. 

The problem is, whenever there is a network flood either syn or icmp or any
other kind, the Linux machine goes into a funny state and the first symtom is
I cannot compile any program. The filesystem gets corrupted. Any amount of fsck
doesn't help. The only way I come out is reinstalling Linux. I have tried RH, 
and Debian the distribution did not matter. There is nothing wrong with the
basic hardware because the system works fine in the ideal network conditions.

So, I have no clue whether it has to do with network handling, or something to 
do with the filesystem support or something else.

Have you encountered this kind of problem ? Or am I the only one :)

I know the group loves to discuss the in-depth core coding issues, but I need
help in isolating my problem.

Thanks.

Anand
