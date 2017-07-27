From: Laura Abbott <labbott@redhat.com>
Subject: Re: [PATCH net] xgene: Don't fail probe, if there is no clk resource
 for SGMII interfaces
Date: Thu, 27 Jul 2017 15:39:58 -0700
Message-ID: <1b3391f2-2fae-2a9a-719d-3f8358e39c71@redhat.com>
References: <20170713092144.31751508094@solo.franken.de>
 <22ee6284-7b23-7664-d6cf-23687f09a3be@redhat.com>
 <20170727213915.GA4902@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: isubramanian@apm.com, kchudgar@apm.com, qnguyen@apm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tom Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170727213915.GA4902@alpha.franken.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/27/2017 02:39 PM, Tom Bogendoerfer wrote:
> On Thu, Jul 27, 2017 at 02:03:42PM -0700, Laura Abbott wrote:
>> This change causes boot failures for me on my APM Mustang system running
>> Fedora rawhide:
>>
>> [   16.669089] Synchronous External Abort: synchronous external abort (0x9600000
>> [   16.669099] Internal error: : 96000010 [#1] SMP                              
>> [   16.669103] Modules linked in: xgene_enet(+) at803x realtek mdio_xgene xgenes
>> [   16.669127] CPU: 2 PID: 534 Comm: systemd-udevd Not tainted 4.13.0-0.rc1.git1
>> [   16.669128] Hardware name: AppliedMicro X-Gene Mustang Board/X-Gene Mustang 6
>> [   16.669131] task: ffff8003e6f8ce00 task.stack: ffff8003e4fd8000              
>> [   16.669144] PC is at xgene_enet_wr_mac+0xa0/0x128 [xgene_enet]               
>> [   16.669152] LR is at xgene_enet_wr_mac+0x64/0x128 [xgene_enet] 
> 
> on the first glance I don't see anything clock related there.
> 

I don't know the intricacies of the Mustang hardware but external
aborts have been a symptom of missing clocks on other hardware.

> What firmware version is installed on your mustang board ? I saw
> ethernet related crashes with mustang boards because the device tree
> in firmware was too old for the xgene ethernet driver.
> 
> Thoms.
> 

TianoCore 3.06.12 UEFI 2.4.0 Aug 12 2016 13:30:51
CPU: APM ARM 64-bit Potenza Rev B0 2400MHz PCP 2400MHz
     32 KB ICACHE, 32 KB DCACHE
     SOC 2000MHz IOBAXI 400MHz AXI 250MHz AHB 200MHz GFC 125MHz
Board: X-Gene Mustang Board
Little Endian build
Slimpro FW:
        Ver: 3.5 (build 03.06.12.00 2016/08/12)
        PMD: 1000 mV
        SOC: 950 mV


Thanks,
Laura
