From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/5] stmmac: pci: Refactor DMI probing
Date: Thu, 22 Jun 2017 13:40:31 -0400 (EDT)
Message-ID: <20170622.134031.1966602928075071150.davem@davemloft.net>
References: <cover.1498112281.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andy.shevchenko@gmail.com
To: jan.kiszka@siemens.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1498112281.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kiszka <jan.kiszka@siemens.com>
Date: Thu, 22 Jun 2017 08:17:56 +0200

> Some cleanups of the way we probe DMI platforms in the driver. Reduces
> a bit of open-coding and makes the logic easier reusable for any
> potential DMI platform != Quark.
> 
> Tested on IOT2000 and Galileo Gen2.
> 
> Changes in v5:
>  - fixed a remaining issue in patch 5
>  - dropped patch 6 for now

Series applied to net-next.

Any chance the DMI table can be marked const as well?
