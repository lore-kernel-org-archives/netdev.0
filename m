From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH net-next] net: stmmac: use correct pointer when printing
 normal descriptor ring
Date: Sun, 28 May 2017 00:59:37 +0300
Message-ID: <CAHp75VfwEGZ9m1_h=JSq4zmX0wy7Qgd-1uSVy3R0KfcSX09p1A@mail.gmail.com>
References: <20170509165202.19023-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Niklas Cassel <niklass@axis.com>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509165202.19023-1-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 9, 2017 at 7:52 PM, Niklas Cassel <niklas.cassel@axis.com> wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>

Commit message?

>                         seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
> -                                  i, (unsigned int)virt_to_phys(ep),
> +                                  i, (unsigned int)virt_to_phys(p),

There is should not be casting. Pointer might be 64-bit, thus %pap
must be used instead with a reference to the physical address.

>                                    le32_to_cpu(p->des0), le32_to_cpu(p->des1),
>                                    le32_to_cpu(p->des2), le32_to_cpu(p->des3));
>                         p++;

-- 
With Best Regards,
Andy Shevchenko
