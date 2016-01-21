From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [PATCH 3/3] net: wireless: rt2x00: Space Required
Date: Thu, 21 Jan 2016 18:10:30 +0100
Message-ID: <CAGXE3d80M6Kxpnc9Ksmkkif-+7+bY96WS2ZKmC3uc0fGeNjGbw@mail.gmail.com>
References: <1445116283-28748-1-git-send-email-paulmcquad@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stanislaw Gruszka <sgruszka@redhat.com>, kvalo@codeaurora.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Paul McQuade <paulmcquad@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445116283-28748-1-git-send-email-paulmcquad@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 17, 2015 at 11:11 PM, Paul McQuade <paulmcquad@gmail.com> wrote:
> Space needed before open parenthesis
>
> Signed-off-by: Paul McQuade <paulmcquad@gmail.com>

Looks valid to me.

Acked-by: Helmut Schaa <helmut.schaa@googlemail.com>

> ---
>  drivers/net/wireless/rt2x00/rt2x00debug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
> index 90fdb02..25ee3cb 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00debug.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
> @@ -629,7 +629,7 @@ static struct dentry *rt2x00debug_create_file_chipset(const char *name,
>         data += sprintf(data, "register\tbase\twords\twordsize\n");
>  #define RT2X00DEBUGFS_SPRINTF_REGISTER(__name)                 \
>  {                                                              \
> -       if(debug->__name.read)                                  \
> +       if (debug->__name.read)                                 \
>                 data += sprintf(data, __stringify(__name)       \
>                                 "\t%d\t%d\t%d\n",               \
>                                 debug->__name.word_base,        \
> @@ -699,7 +699,7 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
>
>  #define RT2X00DEBUGFS_CREATE_REGISTER_ENTRY(__intf, __name)                    \
>  ({                                                                             \
> -       if(debug->__name.read) {                                                \
> +       if (debug->__name.read) {                                               \
>                 (__intf)->__name##_off_entry =                                  \
>                 debugfs_create_u32(__stringify(__name) "_offset",               \
>                                        S_IRUSR | S_IWUSR,                       \
> --
> 2.6.1
>
