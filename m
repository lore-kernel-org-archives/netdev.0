From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: constify clk_div_table
Date: Tue, 29 Aug 2017 10:56:51 -0700 (PDT)
Message-ID: <20170829.105651.2053286906261018644.davem@davemloft.net>
References: <a54fe9764d287df370c16b0f0814d09d8fa24591.1503899422.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khilman@baylibre.com, carlo@caione.org, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, linux-kernel@vger.kernel.org,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a54fe9764d287df370c16b0f0814d09d8fa24591.1503899422.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Mon, 28 Aug 2017 11:22:20 +0530

> clk_div_table are not supposed to change at runtime.
> meson8b_dwmac structure is working with const clk_div_table.
> So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
