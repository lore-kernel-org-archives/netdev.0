From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: via/Kconfig: GENERIC_PCI_IOMAP required if PCI
 not selected
Date: Fri, 25 Sep 2015 12:37:25 -0700 (PDT)
Message-ID: <20150925.123725.9649310331204777.davem@davemloft.net>
References: <1443089813-10967-1-git-send-email-sudipm.mukherjee@gmail.com>
	<56058C88.3070907@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sudipm.mukherjee@gmail.com, egtvedt@samfundet.no,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56058C88.3070907@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 25 Sep 2015 21:03:52 +0300

> Hello.
> 
> On 9/24/2015 1:16 PM, Sudip Mukherjee wrote:
> 
>> The builds of allmodconfig of avr32 is failing with:
>>
>> drivers/net/ethernet/via/via-rhine.c:1098:2: error: implicit
>> declaration
>> of function 'pci_iomap' [-Werror=implicit-function-declaration]
>> drivers/net/ethernet/via/via-rhine.c:1119:2: error: implicit
>> declaration
>> of function 'pci_iounmap' [-Werror=implicit-function-declaration]
>>
>> The generic empty pci_iomap and pci_iounmap is used only if CONFIG_PCI
>> is not defined and CONFIG_GENERIC_PCI_IOMAP is defined.
>>
>> Add GENERIC_PCI_IOMAP in the dependency list for VIA_RHINE as we are
>> getting build failure when CONFIG_PCI and CONFIG_GENERIC_PCI_IOMAP
>> both
>> are not defined.
>>
>> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
 ...
>> @@ -17,7 +17,7 @@ if NET_VENDOR_VIA
>>
>>   config VIA_RHINE
>>   	tristate "VIA Rhine support"
>> -	depends on (PCI || OF_IRQ)
>> +	depends on (PCI || (OF_IRQ && GENERIC_PCI_IOMAP))
> 
>   Could you remove outer braces, while at it?

I took care of this while applying this patch, thanks everyone.
