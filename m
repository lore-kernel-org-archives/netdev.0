From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 1/3] stmmac: pci: Overcome stmmac_pci_info structure
Date: Mon, 22 May 2017 20:09:05 +0300
Message-ID: <CAHp75VdcEFghC6YaEwjBZC1WW87MZxnUC=iXWqfNajAb7A9DAQ@mail.gmail.com>
References: <cover.1495451529.git.jan.kiszka@siemens.com> <5d7b7aa99a04e86196ff7eea11f0ede7a95deac1.1495451529.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5d7b7aa99a04e86196ff7eea11f0ede7a95deac1.1495451529.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 2:12 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> First, pass the PCI device reference as function parameter. Then the
> setup function knows which stmmac_pci_dmi_data structure to use.
> Finally, we are left with a setup function in stmmac_pci_info and can
> convert the structure into a function pointer. By converting
> stmmac_default_data to that type, we can make a setup function
> mandatory, and probing becomes more regular.

I don't see any good reason for this patch. Besides that it will not
compile (as David noticed already).

Can we modify structures with less intrusion?
I'm pretty sure we can convert (if you wish, however I would leave it
for now, there is no issue with current approach) with as twice less
lines.


-- 
With Best Regards,
Andy Shevchenko
