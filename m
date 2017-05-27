From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2 6/6] stmmac: pci: Remove setup handler indirection via stmmac_pci_info
Date: Sat, 27 May 2017 16:38:42 +0300
Message-ID: <CAHp75Vd299jy+4pBUnbbA-2dRL5L=P5jCDtq+WC06WZjdWynRw@mail.gmail.com>
References: <cover.1495814872.git.jan.kiszka@siemens.com> <6183ce221f01384f4d50b0cfd62beabe337f5b39.1495814872.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6183ce221f01384f4d50b0cfd62beabe337f5b39.1495814872.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 26, 2017 at 7:07 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> By now, stmmac_pci_info only contains a single entry.

_For now_.

> Register this
> directly with the PCI device table, removing one indirection.

I am not sure this patch is needed.

Next time something comes up we would need to extend this and
effectively revert this change.
So, my vote is to leave it as is for now.

-- 
With Best Regards,
Andy Shevchenko
