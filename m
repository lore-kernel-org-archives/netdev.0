From: John Partridge <johnip@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 08 Oct 2003 12:52:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F844EF9.9090901@sgi.com>
References: <3F844578.40306@sgi.com> <20031008101046.376abc3b.davem@redhat.com>
Reply-To: johnip@sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031008101046.376abc3b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Not too much different

mig125:~ # nttcp -r -T -l262144 -w1024 -n1000 10.50.1.130 -l262144 -w1024
      Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s   CPU-C/s
l318341120   10.00    9.96    254.6131    255.6215   22500   2249.47    2258.4
1318341120   10.00    0.41    254.6825   6156.0247   19430   1943.07   46966.7

David S. Miller wrote:
> Oh yeah?  What are your numbers like if you just disable the ia64
> kernel unaligned access printk()?

-- 
John Partridge

Silicon Graphics Inc
Tel:  651-683-3428
Vnet: 233-3428
E-Mail: johnip@sgi.com
