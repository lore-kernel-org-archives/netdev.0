From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2 2/6] stmmac: pci: Use stmmac_pci_info for all devices
Date: Sat, 27 May 2017 16:16:43 +0300
Message-ID: <CAHp75VdeO62CCX3YhjBQaprGi7iY+6m5QtcX-CcXj2LpASTrPA@mail.gmail.com>
References: <cover.1495814872.git.jan.kiszka@siemens.com> <dc0eaa024838f4ef34913aed63315771ac81dcc1.1495814872.git.jan.kiszka@siemens.com>
 <CAHp75Ve=CJ-ZRmaAFX+tezMJ4u11v=ptrDDORF485f3_iFEWeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75Ve=CJ-ZRmaAFX+tezMJ4u11v=ptrDDORF485f3_iFEWeg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 27, 2017 at 4:13 PM, Andy Shevchenko
<andy.shevchenko@gmail.com> wrote:
> On Fri, May 26, 2017 at 7:07 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>> Make stmmac_default_data compatible with stmmac_pci_info.setup and use
>> an info structure for all devices. This allows to make the probing more
>> regular.

> Or converting defines first to PCI_DEVICE_ID_*

It looks even for previously mentioned approach we need to rename
constants first.

> and
>
> #define STMMAC_DEVICE(_vid, _did, info) {       \
>        PCI_DEVICE(PCI_VENDOR_ID_##_vid, PCI_DEVICE_ID_##_did),
>          \
>
> which I like even better.

Or even
 #define STMMAC_DEVICE(_vid, _did, info) {       \
        PCI_VDEVICE(_vid, PCI_DEVICE_ID_##_did),        \


-- 
With Best Regards,
Andy Shevchenko
