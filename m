From: David Greaves <david@dgreaves.com>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+ delay
 scheduler
Date: Mon, 21 Jun 2004 19:34:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D72A4A.2080007@dgreaves.com>
References: <Pine.LNX.4.44.0406211042410.27923-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tharbaugh@lnxi.com, Jens Laas <jens.laas@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ganesh.venkatesan@intel.com
In-Reply-To: <Pine.LNX.4.44.0406211042410.27923-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OK
applied patch

ifdown eth1; modprobe -r e1000;modprobe e1000;ifup eth1; ifconfig eth1 
mtu 9000
(so no reboot)

dmesg:
e1000: Ignoring new-style parameters in presence of obsolete ones
Intel(R) PRO/1000 Network Driver - version 5.2.52-k4
Copyright (c) 1999-2004 Intel Corporation.
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
e1000: eth1: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex
ifconfig: page allocation failure. order:3, mode:0x20
 [<c01310a8>] __alloc_pages+0x2d8/0x350
 [<c0131145>] __get_free_pages+0x25/0x40
 [<c0134620>] kmem_getpages+0x20/0xb0
 [<c0135186>] cache_grow+0xa6/0x200
 [<c0135436>] cache_alloc_refill+0x156/0x220
 [<c01359f4>] __kmalloc+0x74/0x80
 [<c02a3427>] alloc_skb+0x47/0xe0
 [<f89e45a2>] e1000_alloc_rx_buffers+0x62/0x100 [e1000]
 [<f89e1045>] e1000_up+0x45/0xb0 [e1000]
 [<f89e363c>] e1000_change_mtu+0x7c/0x110 [e1000]
 [<c02a8ea9>] dev_set_mtu+0x79/0x90
 [<c02a94a5>] dev_ioctl+0x1f5/0x280
 [<c02e271e>] inet_ioctl+0x8e/0xa0
 [<c02a0039>] sock_ioctl+0xe9/0x290
 [<c015c50f>] sys_ioctl+0xef/0x260
 [<c0110570>] do_page_fault+0x0/0x4da
 [<c0103fb7>] syscall_call+0x7/0xb

ifconfig: page allocation failure. order:3, mode:0x20
 [<c01310a8>] __alloc_pages+0x2d8/0x350
 [<c0131145>] __get_free_pages+0x25/0x40
 [<c0134620>] kmem_getpages+0x20/0xb0
 [<c0135186>] cache_grow+0xa6/0x200
 [<c0135436>] cache_alloc_refill+0x156/0x220
 [<c0111a1a>] wake_up_state+0x1a/0x20
 [<c01359f4>] __kmalloc+0x74/0x80
 [<c02a3427>] alloc_skb+0x47/0xe0
 [<f89e45a2>] e1000_alloc_rx_buffers+0x62/0x100 [e1000]
 [<f89e41e7>] e1000_clean_rx_irq+0xf7/0x450 [e1000]
 [<c011175f>] recalc_task_prio+0x8f/0x190
 [<f89e3e73>] e1000_clean+0x43/0xc0 [e1000]
 [<c02a861a>] net_rx_action+0x6a/0xf0
 [<c01190bd>] __do_softirq+0x7d/0x80
 [<c01190e6>] do_softirq+0x26/0x30
 [<c0105ded>] do_IRQ+0xfd/0x130
 [<c0104124>] common_interrupt+0x18/0x20
 [<f89e3d37>] e1000_irq_enable+0x27/0x30 [e1000]
 [<f89e109d>] e1000_up+0x9d/0xb0 [e1000]
 [<f89e363c>] e1000_change_mtu+0x7c/0x110 [e1000]
 [<c02a8ea9>] dev_set_mtu+0x79/0x90
 [<c02a94a5>] dev_ioctl+0x1f5/0x280
 [<c02e271e>] inet_ioctl+0x8e/0xa0
 [<c02a0039>] sock_ioctl+0xe9/0x290
 [<c015c50f>] sys_ioctl+0xef/0x260
 [<c0110570>] do_page_fault+0x0/0x4da
 [<c0103fb7>] syscall_call+0x7/0xb

kdeinit: page allocation failure. order:3, mode:0x20
 [<c01310a8>] __alloc_pages+0x2d8/0x350
 [<c0131145>] __get_free_pages+0x25/0x40
 [<c0134620>] kmem_getpages+0x20/0xb0
 [<c0135186>] cache_grow+0xa6/0x200
 [<c0135436>] cache_alloc_refill+0x156/0x220
 [<c01359f4>] __kmalloc+0x74/0x80
 [<c02a3427>] alloc_skb+0x47/0xe0
 [<f89e45a2>] e1000_alloc_rx_buffers+0x62/0x100 [e1000]
 [<f89e41e7>] e1000_clean_rx_irq+0xf7/0x450 [e1000]
 [<f89e3e73>] e1000_clean+0x43/0xc0 [e1000]
 [<c02a861a>] net_rx_action+0x6a/0xf0
 [<c01190bd>] __do_softirq+0x7d/0x80
 [<c01190e6>] do_softirq+0x26/0x30
 [<c0105ded>] do_IRQ+0xfd/0x130
 [<c0104124>] common_interrupt+0x18/0x20
...

David

ganesh.venkatesan@intel.com wrote:

>David:
>
>Could you try the following patch to workaround the meemory allocation 
>issue you are reporting? 
>
>---------------------
>--- e1000_main.c	2004-06-21 10:37:29.496090824 -0700
>+++ e1000_main.c-patched	2004-06-21 10:37:06.920522832 -0700
>@@ -796,7 +796,7 @@ e1000_setup_tx_resources(struct e1000_ad
> 	int size;
> 
> 	size = sizeof(struct e1000_buffer) * txdr->count;
>-	txdr->buffer_info = kmalloc(size, GFP_KERNEL);
>+	txdr->buffer_info = vmalloc(size);
> 	if(!txdr->buffer_info) {
> 		return -ENOMEM;
> 	}
>@@ -809,7 +809,7 @@ e1000_setup_tx_resources(struct e1000_ad
> 
> 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
> 	if(!txdr->desc) {
>-		kfree(txdr->buffer_info);
>+		vfree(txdr->buffer_info);
> 		return -ENOMEM;
> 	}
> 	memset(txdr->desc, 0, txdr->size);
>@@ -913,7 +913,7 @@ e1000_setup_rx_resources(struct e1000_ad
> 	int size;
> 
> 	size = sizeof(struct e1000_buffer) * rxdr->count;
>-	rxdr->buffer_info = kmalloc(size, GFP_KERNEL);
>+	rxdr->buffer_info = vmalloc(size);
> 	if(!rxdr->buffer_info) {
> 		return -ENOMEM;
> 	}
>@@ -927,7 +927,7 @@ e1000_setup_rx_resources(struct e1000_ad
> 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
> 
> 	if(!rxdr->desc) {
>-		kfree(rxdr->buffer_info);
>+		vfree(rxdr->buffer_info);
> 		return -ENOMEM;
> 	}
> 	memset(rxdr->desc, 0, rxdr->size);
>@@ -1051,7 +1051,7 @@ e1000_free_tx_resources(struct e1000_ada
> 
> 	e1000_clean_tx_ring(adapter);
> 
>-	kfree(adapter->tx_ring.buffer_info);
>+	vfree(adapter->tx_ring.buffer_info);
> 	adapter->tx_ring.buffer_info = NULL;
> 
> 	pci_free_consistent(pdev, adapter->tx_ring.size,
>@@ -1120,7 +1120,7 @@ e1000_free_rx_resources(struct e1000_ada
> 
> 	e1000_clean_rx_ring(adapter);
> 
>-	kfree(rx_ring->buffer_info);
>+	vfree(rx_ring->buffer_info);
> 	rx_ring->buffer_info = NULL;
> 
> 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
>--- e1000.h	2004-06-21 10:37:29.523086720 -0700
>+++ e1000.h-patched	2004-06-21 10:37:15.506217608 -0700
>@@ -49,6 +49,7 @@
> #include <linux/delay.h>
> #include <linux/timer.h>
> #include <linux/slab.h>
>+#include <linux/vmalloc.h>
> #include <linux/interrupt.h>
> #include <linux/string.h>
> #include <linux/pagemap.h>
>@@ -159,9 +160,9 @@ struct e1000_adapter;
> struct e1000_buffer {
> 	struct sk_buff *skb;
> 	uint64_t dma;
>-	unsigned long length;
> 	unsigned long time_stamp;
>-	unsigned int next_to_watch;
>+	uint16_t next_to_watch;
>+	uint16_t length;
> };
> 
> struct e1000_desc_ring {
>----------------------
>ganesh.
>
>On Mon, 21 Jun 2004, David Greaves wrote:
>
>  
>
>>Thayne Harbaugh wrote:
>>
>>    
>>
>>>On Fri, 2004-06-18 at 03:08, David Greaves wrote:
>>>
>>> 
>>>
>>>      
>>>
>>>>Jens Laas wrote:
>>>>   
>>>>
>>>>        
>>>>
>>>>>We have tried different versions of e1000 without luck.
>>>>>     
>>>>>
>>>>>          
>>>>>
>>>>Me too, 3 cards.
>>>>(did I mention I have 2 machines with very similar specs (AMD/VIAKT600)
>>>>and the other one works - actually, to be accurate, hasn't yet failed
>>>>but hasn't yet run at full speed - and it has a higher CPU speed)
>>>>   
>>>>
>>>>        
>>>>
>>>What do you mean by, ". . . hasn't yet run at full speed - and it has a
>>>higher CPU speed . . ." ?  Does this mean that you can't get the card to
>>>have a reasonable throughput (~900Mbps)?
>>>
>>> 
>>>
>>>      
>>>
>>It sounded reasonable when I wrote it :)
>>
>>I have 2 machines I can easily test with (wired back to back)
>>Machine 1 has an AMD3000+ CPU, machine 2 has an AMD3200+ cpu (maybe not
>>relevant - maybe important if it's timing related?)
>>
>>Machine one  stalls within a few kb.
>>Machine two has shown no signs of failure yet.
>>
>>However the other machine has not been stressed at all so it has 'not
>>yet run at full speed' - not surprising since it has no friends with
>>working gigabit cards :)
>>
>>David
>>PS
>>I tried some experiments this weekend with a third machine but I got
>>nasty kernel oopses on the second (supposedly good) whenever I did
>>ifconfig eth1 mtu 9000 and I've not had time to get any proper results
>>or a minimal failure yet.
>>
>>simply issuing
>>ifconfig eth1 mtu 9000
>>on the second machine gave me this:
>>
>>Jun 18 16:33:08 haze kernel: printk: 1 messages suppressed.
>>Jun 18 16:33:08 haze kernel: ifconfig: page allocation failure. order:3,
>>mode:0x20
>>Jun 18 16:33:08 haze kernel:  [__alloc_pages+728/848]
>>__alloc_pages+0x2d8/0x350
>>Jun 18 16:33:08 haze kernel:  [__get_free_pages+37/64]
>>__get_free_pages+0x25/0x40
>>Jun 18 16:33:08 haze kernel:  [kmem_getpages+32/176] kmem_getpages+0x20/0xb0
>>Jun 18 16:33:08 haze kernel:  [cache_grow+166/512] cache_grow+0xa6/0x200
>>Jun 18 16:33:08 haze kernel:  [cache_alloc_refill+342/544]
>>cache_alloc_refill+0x156/0x220
>>Jun 18 16:33:08 haze kernel:  [__kmalloc+116/128] __kmalloc+0x74/0x80
>>...
>>
>>I'll report more fully when I can produce something consistent.
>>
>>
>>
>>    
>>
>
>
>  
>
