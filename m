From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [W1]: Remove incorrect MODULE_ALIAS
Date: Sun, 8 Jan 2006 12:40:54 +0300
Message-ID: <20060108094054.GA21124@2ka.mipt.ru>
References: <43C0524F.1030602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	GregKH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030584AbWAHJlB@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <43C0524F.1030602@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 08, 2006 at 12:44:15AM +0100, Patrick McHardy (kaber@trash.net) wrote:

> [W1]: Remove incorrect MODULE_ALIAS
> 
> The w1 netlink socket is created by a hardware specific driver calling
> w1_add_master_device, so there is no point in including a module alias
> for netlink autoloading in the core.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

ACK.
Thanks, Patrick.

> ---
> commit a8657adb8c04bbe30544306ec55005a635ba65fd
> tree 2c029cf104239958220629d34c76c7290bd99e43
> parent b73952761225e41cb81afe157cb312a594a95693
> author Patrick McHardy <kaber@trash.net> Sun, 08 Jan 2006 00:42:42 +0100
> committer Patrick McHardy <kaber@trash.net> Sun, 08 Jan 2006 00:42:42 +0100
> 
>  drivers/w1/w1_int.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/w1/w1_int.c b/drivers/w1/w1_int.c
> index c3f67ea..e2920f0 100644
> --- a/drivers/w1/w1_int.c
> +++ b/drivers/w1/w1_int.c
> @@ -217,5 +217,3 @@ void w1_remove_master_device(struct w1_b
>  
>  EXPORT_SYMBOL(w1_add_master_device);
>  EXPORT_SYMBOL(w1_remove_master_device);
> -
> -MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_W1);


-- 
	Evgeniy Polyakov
