From: Ben Greear <greearb@candelatech.com>
Subject: Re: Ethernet bridge performance
Date: Sun, 10 Aug 2003 11:13:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F368B3A.3070009@candelatech.com>
References: <3F3217E7.2080903@allot.com> <3F3284EA.5050406@candelatech.com> <3F328A0F.3040005@allot.com> <16178.41976.3643.584516@robur.slu.se> <3F3601F3.6000001@allot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com,
   "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Felix Radensky <felix@allot.com>
In-Reply-To: <3F3601F3.6000001@allot.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Felix Radensky wrote:

> I've mentioned in my first post that there are zero drops at driver level
> (as shown by ifconfig). I'm also using IRQ affinity feature, binding 
> interrupts
> of eth0 and eth1 to CPU0, so I guess NIC ring RX/TX size, link HW_FLOW 
> control
> and affinity are not my problems.

Maybe try un-binding the cpus, or binding them to different procs?

> 
> Speaking of checksumming. This can be a problem indeed. ethtool -S shows 
> a lot
> of rx_csum_offload errors. Scott, what could possibly be a problem ? The 
> NIC
> is dual port 82546, driver is 5.1.13-k1.

Why would a bridge be checksumming anything?

> 
> I've failed to find a discussion about ksoftird priority. Can someone 
> please
> provide a link.

I've increased my performance by setting softirqd priority to -18,
but since you seem to be dropping someplace other than the driver,
I'm not sure that will help.

> 
> Thanks a lot.
> 
> Felix.
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
