From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: strange e1000 performance issues
Date: Fri, 09 Apr 2004 03:23:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40764F89.8090306@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've got a pair of dual G5s running 2.6.4.  For a second gigE link we 
added in some Intel 82540EM cards, using the mainline e1000 driver with 
NAPI enabled.  lspci reports the bus as 66MHz.  The cards were connected 
together with a crossover cable.

A basic UDP packet-blasting program in userspace using 64KB datagrams 
could only manage 47MB/s of data throughput, using 20% of a cpu.

For comparison, the same program managed 108.9 MB/s with 30% cpu when 
using the onboard gigE ports.

Also, I tried setting a larger mtu using "ip set link dev ethx mtu 
xxxxx".  No matter what value I chose (even setting it to its default 
value, which should have had zero effect) it resulted in the link not 
being able to transfer data.  Downing/upping the link didn't clear the 
issue, neither did unloading/reloading the driver module.  It took a 
reboot to actually get it working again.

Any ideas what's going on?

Thanks,

Chris
