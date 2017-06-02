From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v4 5/6] stmmac: pci: Use dmi_system_id table for
 retrieving PHY addresses
Date: Fri, 2 Jun 2017 13:43:50 +0300
Message-ID: <CAHp75VfaiP_Q59+iQ5ZC8O2gKOeR-gwdJpO5b05MFRdTzagR8A@mail.gmail.com>
References: <cover.1496388893.git.jan.kiszka@siemens.com> <33942c3893beaca0f82528386fa3b239a6a02f02.1496388893.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <33942c3893beaca0f82528386fa3b239a6a02f02.1496388893.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 2, 2017 at 10:34 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> Avoids reimplementation of DMI matching in stmmac_pci_find_phy_addr.

> +static const struct stmmac_pci_func_data galileo_stmmac_func_data[] = {
>         {
>                 .func = 6,
>                 .phy_addr = 1,
>         },

> +       { },

Now this is redundant.

> +};

> +static const struct stmmac_pci_dmi_data galileo_stmmac_dmi_data = {
> +       .func = galileo_stmmac_func_data,
> +       .nfuncs = ARRAY_SIZE(galileo_stmmac_func_data),

It will be 2, when is supposed to be 1, see above.

> +};

> +static const struct stmmac_pci_func_data iot2040_stmmac_func_data[] = {

> +       { },
> +};

> +       .nfuncs = ARRAY_SIZE(iot2040_stmmac_func_data),

Ditto.

-- 
With Best Regards,
Andy Shevchenko
