From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: Compilation error on drivers/md/raid6int8.c on net-next-2.6
Date: Wed, 16 Jul 2008 17:06:01 -0300
Message-ID: <487E54A9.6080606@linux.vnet.ibm.com>
References: <487E364C.3050200@linux.vnet.ibm.com> <20080716183128.GG17329@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:40853 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242AbYGPULt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 16:11:49 -0400
In-Reply-To: <20080716183128.GG17329@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> On Wed, Jul 16, 2008 at 02:56:28PM -0300, Breno Leitao wrote:
>   
>> drivers/md/raid6int8.c: In function `raid6_int8_gen_syndrome':
>> drivers/md/raid6int8.c:185: error: unable to find a register to spill in  
>> class `FLOAT_REGS'
>> drivers/md/raid6int8.c:185: error: this is the insn:
>> (insn:HI 619 799 638 4 drivers/md/raid6int8.c:168 (set (mem:DI (plus:DI  
>> (reg/v/f:DI 122 [ p ])
>>                (reg/v:DI 66 ctr [orig:124 d ] [124])) [0 S8 A64])
>>        (reg/v:DI 129 [ wp0 ])) 320 {*movdi_internal64} (nil)
>>    (expr_list:REG_DEAD (reg/v:DI 129 [ wp0 ])
>>        (nil)))
>> drivers/md/raid6int8.c:185: confused by earlier errors, bailing out
>> make[2]: *** [drivers/md/raid6int8.o] Error 1
>> make[1]: *** [drivers/md] Error 2
>> make: *** [drivers] Error 2
>>     
>
> That's a gcc bug.
>
> Which gcc version are you using?
I was using a RHEL4 machine (gcc version  3.4.6).  I just upgraded  gcc 
to 4.1.2, and the "problem"  just disappeared.  :-)

Thanks
Breon
