From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] stmmac: Add support for SIMATIC IOT2000 platform
Date: Tue, 25 Apr 2017 00:27:53 +0300
Message-ID: <CAHp75VcdpOXa+aQ6-iKamTAbX9KGZOWpukygSUS7Ef_E3UNvuw@mail.gmail.com>
References: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Sascha Weisenberger <sascha.weisenberger@siemens.com>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 24, 2017 at 10:27 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> The IOT2000 is industrial controller platform, derived from the Intel
> Galileo Gen2 board. The variant IOT2020 comes with one LAN port, the
> IOT2040 has two of them. They can be told apart based on the board asset
> tag in the DMI table.
>
> Based on patch by Sascha Weisenberger.
>

> Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
> Signed-off-by: Sascha Weisenberger <sascha.weisenberger@siemens.com>

Shoudn't be ordered other way around?

> +       const char *asset_tag;

I guess this is redundant. See below.

> +       {
> +               .name = "SIMATIC IOT2000",
> +               .asset_tag = "6ES7647-0AA00-0YA2",
> +               .func = 6,
> +               .phy_addr = 1,
> +       },

The below has same definition disregard on asset_tag.

> +       {
> +               .name = "SIMATIC IOT2000",
> +               .asset_tag = "6ES7647-0AA00-1YA2",
> +               .func = 6,
> +               .phy_addr = 1,
> +       },
> +       {
> +               .name = "SIMATIC IOT2000",
> +               .asset_tag = "6ES7647-0AA00-1YA2",
> +               .func = 7,
> +               .phy_addr = 1,
> +       },

How this supposed to work if phy_addr is the same?

-- 
With Best Regards,
Andy Shevchenko
