From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: Re: [PATCH 0/3] stmmac: pci: Refactor DMI probing
Date: Mon, 22 May 2017 19:06:07 +0200
Message-ID: <16d9bbf6-0579-f16c-4177-251fa3837a2a@siemens.com>
References: <cover.1495451529.git.jan.kiszka@siemens.com>
 <20170522.123555.2260863464877381826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: 8bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andy.shevchenko@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522.123555.2260863464877381826.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-05-22 18:35, David Miller wrote:
> From: Jan Kiszka <jan.kiszka@siemens.com>
> Date: Mon, 22 May 2017 13:12:06 +0200
> 
>> Some cleanups of the way we probe DMI platforms in the driver. Reduces
>> a bit of open-coding and makes the logic easier reusable for any
>> potential DMI platform != Quark.
>>
>> Tested on IOT2000 and Galileo Gen2.
> 
> This doesn't compile:
> 
> drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c:285:3: error: initializer element is not computable at load time
>    (kernel_ulong_t)&stmmac_default_setup,
>    ^
> drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c:285:3: note: (near initialization for ¡stmmac_id_table[0].class¢)
> drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c:289:3: error: initializer element is not computable at load time
>    (kernel_ulong_t)&stmmac_default_setup,
>    ^
> drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c:289:3: note: (near initialization for ¡stmmac_id_table[1].class¢)
> scripts/Makefile.build:302: recipe for target 'drivers/net/ethernet/stmicro/stmmac/stmmac_pci.o' failed
> make[5]: *** [drivers/net/ethernet/stmicro/stmmac/stmmac_pci.o] Error 1
> 

Hmm. Which arch is this?

Jan
