From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: make mdiobb_ops const
Date: Tue, 22 Aug 2017 15:03:37 +0300
Message-ID: <1f074a7c-0d3a-e569-4400-c50d967e550c@cogentembedded.com>
References: <1503389282-17369-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1503389282-17369-1-git-send-email-bhumirks@gmail.com>
Content-Language: en-MW
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 08/22/2017 11:08 AM, Bhumika Goyal wrote:

> Make these const as they are only stored in a const field of a
> mdiobb_ctrl structure.

> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
>   drivers/net/ethernet/renesas/ravb_main.c | 2 +-
>   drivers/net/ethernet/renesas/sh_eth.c    | 2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)

    If you're fixing both Renesas drivers at once, your subject should be 
"renesas: make mdiobb_ops const". With that fixed, you have my:

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
