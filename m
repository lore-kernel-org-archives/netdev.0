From: Bhumika Goyal <bhumirks@gmail.com>
Subject: Re: [PATCH] netconsole: make config_item_type const
Date: Thu, 12 Oct 2017 17:04:06 +0200
Message-ID: <CAOH+1jER7Ra+pwPYGS8Y1kB6SYrQjxzOfAfgpyb=Nbt_7a2wmQ@mail.gmail.com>
References: <1507811352-9962-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: Julia Lawall <julia.lawall@lip6.fr>,
        David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
        nab@linux-iscsi.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507811352-9962-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2017 at 2:29 PM, Bhumika Goyal <bhumirks@gmail.com> wrote:
> This is a followup patch for: https://lkml.org/lkml/2017/10/11/375 and
> https://patchwork.kernel.org/patch/9999649/
>
> Make these structures const as they are either passed to the functions
> having the argument as const or stored as a reference in the "ci_type"
> const field of a config_item structure.
>
> Done using Coccienlle.
>

Actually, this patch is dependent on the patches in the links
https://lkml.org/lkml/2017/10/11/375 and
https://patchwork.kernel.org/patch/9999649/. Therefore, this patch
won't be correct unless the patches in these links gets applied.

> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
>  drivers/net/netconsole.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index 0e27920..be9aa36 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -616,7 +616,7 @@ static void netconsole_target_release(struct config_item *item)
>         .release                = netconsole_target_release,
>  };
>
> -static struct config_item_type netconsole_target_type = {
> +static const struct config_item_type netconsole_target_type = {
>         .ct_attrs               = netconsole_target_attrs,
>         .ct_item_ops            = &netconsole_target_item_ops,
>         .ct_owner               = THIS_MODULE,
> @@ -682,7 +682,7 @@ static void drop_netconsole_target(struct config_group *group,
>         .drop_item      = drop_netconsole_target,
>  };
>
> -static struct config_item_type netconsole_subsys_type = {
> +static const struct config_item_type netconsole_subsys_type = {
>         .ct_group_ops   = &netconsole_subsys_group_ops,
>         .ct_owner       = THIS_MODULE,
>  };
> --
> 1.9.1
>
