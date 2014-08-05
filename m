From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] drivers/isdn/hisax/Kconfig: Let HISAX_NETJET skip microblaze
 architecture
Date: Tue, 05 Aug 2014 12:21:29 +0800
Message-ID: <53E05BC9.3060500@gmail.com>
References: <53DFCFC9.6060307@gmail.com>	<20140804212354.74b97cd7@endymion.delvare> <CAMuHMdVGgW11UziFieCgXT7mSNA=_QgOaGAt42kEXqU9CUgqxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Michal Simek <monstr@monstr.eu>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	Jean Delvare <jdelvare@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVGgW11UziFieCgXT7mSNA=_QgOaGAt42kEXqU9CUgqxA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/05/2014 03:44 AM, Geert Uytterhoeven wrote:
> On Mon, Aug 4, 2014 at 9:23 PM, Jean Delvare <jdelvare@suse.de> wrote:
>>> --- a/drivers/isdn/hisax/Kconfig
>>> +++ b/drivers/isdn/hisax/Kconfig
>>> @@ -237,7 +237,7 @@ config HISAX_MIC
>>>
>>>  config HISAX_NETJET
>>>       bool "NETjet card"
>>> -     depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
>>> +     depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
>>>       depends on VIRT_TO_BUS
>>>       help
>>>         This enables HiSax support for the NetJet from Traverse
>>> @@ -249,7 +249,7 @@ config HISAX_NETJET
>>>
>>>  config HISAX_NETJET_U
>>>       bool "NETspider U card"
>>> -     depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
>>> +     depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
>>>       depends on VIRT_TO_BUS
>>>       help
>>>         This enables HiSax support for the Netspider U interface ISDN card
>>
>> Fine with me, however the list is getting long. It would be better if
>> we could depend on a functional symbol rather than a negated list of
>> architectures. Would it make sense to have CONFIG_CPU_LITTLE_ENDIAN
>> defined on all little-endian architectures, so that driver can depend
>> on that if needed?
> 
> Yes, that idea pops up once in a while.
> 
> BTW, these days little endian PPC is also supported by Linux...
> 
>> Alternatively, it might make more sense to list the architectures where
>> these drivers are actually used in practice. I guess that's X86, maybe
>> ARM and IA64, and that's all?
> 
> || COMPILE_TEST ....
> 

OK, thanks, what all of you said sounds reasonable to me.

Hello Geert:

Could you help send the related patch for it?


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
