From: Lars Landmark <larslan@merete.zapto.org>
Subject: class/qdisc question
Date: Tue, 18 Mar 2003 19:22:08 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303181857500.12317-100000@merete.balder.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

HI;

I am trying to write my own class based queue. But as usual some problems 
seems not to be resolved.

I have achieved to send package through my queue.  This can be done if I 
not attach class or filters.  If I do try to attach class or filter, my 
computer stops. I can not read any message, nor do anything. My only 
choice is to push power button in order to reboot.  

My "queue" is compiled as module and if I do "insmod", 
it is loaded in to kernel.  This operation do not report any error.

[root@lars larslan]# /sbin/insmod sch_kll
Using /lib/modules/2.4.20/kernel/net/sched/sch_kll.o


/sbin/lsmod  report
Module                  Size  Used by    Not tainted
sch_htb                21088   1
sch_kll                9608    0 (autoclean) (unused)
3c59x                  28520   2


When I now configure this module width my patched tc file 
************
root@lars iproute2.lars]# ./tc/tc qdisc add dev eth0 root handle 1: kll   
default 5
************
output from /sbin/lsmod do not change. It still says used by 0 and 
(unused).

I have written som output in every procedyre, and dmesg report that this 
procedures are called
*************
[root@lars iproute2.lars]# dmesg
KLL: inne i classify?
KLL: inne i dequeue?
KLL: inne i dequeue?
....
*************
So my question is, how can this happen? 
I thought that at once I configure module, 
modules usage count would be incremented???
Is there any possibility, that when I attach a filter my computer crash 
because kernel do not know kll-module is in use???

I would be very happy if some could tell me what I have been missed...

Any suggestion is appreciated, 
Thanks in advance

Lars 
Student 
