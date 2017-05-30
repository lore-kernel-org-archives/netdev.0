From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3 0/6] stmmac: pci: Refactor DMI probing
Date: Tue, 30 May 2017 21:48:05 +0300
Message-ID: <CAHp75VcGNr78mfGgtrKuZJtLppv=rAJ4Bxejcec3MhnC6ejSjQ@mail.gmail.com>
References: <cover.1496129604.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1496129604.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 10:33 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> Some cleanups of the way we probe DMI platforms in the driver. Reduces
> a bit of open-coding and makes the logic easier reusable for any
> potential DMI platform != Quark.
>
> Tested on IOT2000 and Galileo Gen2.

So, for patches 1-4,
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>

I'm not convinced that patch 6 is needed, so, my vote is not to include it.

Patch 5 I would like to review later. Main problem to me is {-1, -1}.
It looks non-standard and feels not good. I'll try to think on the
solution.

> Jan Kiszka (6):
>   stmmac: pci: Make stmmac_pci_info structure constant
>   stmmac: pci: Use stmmac_pci_info for all devices
>   stmmac: pci: Make stmmac_pci_find_phy_addr truly generic
>   stmmac: pci: Select quark_pci_dmi_data from quark_default_data
>   stmmac: pci: Use dmi_system_id table for retrieving PHY addresses
>   stmmac: pci: Remove setup handler indirection via stmmac_pci_info

-- 
With Best Regards,
Andy Shevchenko
