From: Jeff Garzik <jeff@garzik.org>
Subject: Re: 2.6.23-rc4-mm1 OOPS in forcedeth?
Date: Sat, 01 Sep 2007 15:05:19 -0400
Message-ID: <46D9B7EF.2050109@garzik.org>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070901181352.GA4156@amd64.of.nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: thunder7@xs4all.nl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756489AbXIATFg@vger.kernel.org>
In-Reply-To: <20070901181352.GA4156@amd64.of.nowhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

thunder7@xs4all.nl wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Fri, Aug 31, 2007 at 09:58:22PM -0700
>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/
>>
> On this machine (Athlon 64 X2 4600, 4 GiB memory, lots of disks),
> 2.6.23-rc1-mm2 runs fine. 2.6.23-rc4-mm1 reproducably dies within seconds of starting
> a rsync session on another PC against this machine.
> 
> NULL pointer dereference
> code:	nv_napi_poll+0x108
> trace:	net_rx_action+0xab
> 	__do_softirq+0x74
> 	call_softirq+0x1c
> 	do_softirq+0x3d
> 	irq_exit+0x85
> 	do_IRQ+0x85
> 	ret_from_intr+0x0

(added netdev to CC)

I'm guessing that this is net-2.6.24.git's NAPI update.

	Jeff
