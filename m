From: Ben Greear <greearb@candelatech.com>
Subject: Re: buffer overruns
Date: Sat, 24 Apr 2004 00:55:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <408A1D73.5030705@candelatech.com>
References: <Pine.GSO.4.10.10404241055580.17512-100000@cseultra3.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ramesh Chaurasiya <rchaurasiya@cse.iitk.ac.in>
In-Reply-To: <Pine.GSO.4.10.10404241055580.17512-100000@cseultra3.cse.iitk.ac.in>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ramesh Chaurasiya wrote:
> Hi,
>   Whenever I try to receive traffic at more than 500 Mbps, many packets
> are being dropped as shown in ifconfig. There are many overruns and errors
> in Rx packets details of ifconfig. I am using Intel PRO 1000 Gigabit NIC,
> linux 2.4.20-8smp and dual processsor Xeon Machine with a 32bit/33 MHz PCI
> bus. What does this error means. Am I dropping packets at
> NIC/driver/kernel buffers/application socket? What new hardware should I
> use to overcome this. I am using latest e1000 drivers compiled with NAPI
> support. Please help me out.
> Thanks,
> Ramesh.

Get a 64-bit PCI-X bus, and set the RxDescriptors and TxDescriptors
in the e1000 driver to 4096.

With that, I can get about 999Mbps rx + tx on two ports.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
