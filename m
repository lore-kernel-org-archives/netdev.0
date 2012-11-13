From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: RE: e1000e on DH55HC stalling and kernel panic in 3.6.6
Date: Wed, 14 Nov 2012 00:33:15 +0200
Message-ID: <88b9f5243efcbb07cd474cf3f0ede6e4@visp.net.lb>
References: <46948b0ae98fcae5d08fd9fe61fd2e47@visp.net.lb>
 <061C8A8601E8EE4CA8D8FD6990CEA8913348A9F7@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA8913348A9F7@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012-11-13 21:41, Dave, Tushar N wrote:
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org 
>> [mailto:netdev-owner@vger.kernel.org]
>>On Behalf Of Denys Fedoryshchenko
>>Sent: Tuesday, November 13, 2012 5:59 AM
>>To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
>>Carolyn; Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P;
>>Duyck, Alexander H; Ronciak, John; e1000-devel@lists.sourceforge.net;
>>netdev@vger.kernel.org; linux-kernel@vger.kernel.org
>>Subject: e1000e on DH55HC stalling and kernel panic in 3.6.6
>>
>>Hi
>>
>>I just tried to run latest kernel on my DH55HC motherboard latest 
>> kernel
>>3.6.6 and got various network problems, such as network traffic are
>>stopping, and sometimes i am getting kernel panic.
>>When traffic are stopping, ethtool -r eth0 sometimes helps.
>>When i do ethtool -G eth0 rx NNN , sometimes it will give kernel 
>> panic,
>>but it is hard to reproduce.
>>
>>I tried to capture panic on pictures, so will try to decode on what i 
>> got
>>photo, it is a nightmare, but sadly i dont have serial in hands to 
>> get
>>data over it.
>>
>>skbuff: skb_over_panic: text:f86fc769 len:25807 put:25807 
>> head:c1da1800
>>data:c1da1840 tail:0xc1da7d0f end:c1da1f40 dev:eth0 kernel BUG at
>>net/core/skbuff.c:127
>>opcode: 0000 [#1] SMP
>>Pid: 0 comm: swapper/6 Not tained 3.6.6-build-0063 #23
>>EIP: 0060:[<c02e7980>] EFLAGS: 00010296 CPU:6 EIP is at 
>> skb_put+0x83/0x8e
>>
>>There is registers and stack, let me know if you need specific fields
>>
>>Call trace:
>>f86fc769 ? e1000_clean_rx_irq+0x1e1/0x2af [e1000e]
>>f86fc769 e1000_clean_rx_irq+0x1e1/0x2af [e1000e]
>>f86fcc73 e1000e_poll+0x6a/0x209 [e1000e]
>>c02f1630 net_rx_action+0x90/0x15d
>>c01302d5 __do_softirq+0x8a/-x13b
>>c013024b ? local_bh_enable+0xd/0xd
>><IRQ>
>>c0130504 irq_exit+0x41/0x91
>>c0102c37 do_IRQ+0x79/0x8d
>>
>>There is also more data, let me know if you need it.
> Yes, please send us the full dmesg log with error.
> Have you tried out-of-tree e1000e driver?
>
> -Tushar
It is kernel panic, and screen is not good that i am unable to get 
proper photo.
Should i try to make photos and send them as pictures?
I will try to get also tomorrow USB Serial, and probably i can output 
there panic message.

I will try also out of tree e1000e tomorrow first.


---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
