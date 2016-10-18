From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH 1/1] net: vlan: Use sizeof instead of literal number
Date: Tue, 18 Oct 2016 08:59:58 +0800
Message-ID: <CA+6hz4ryFfMGK9q_AvR2LSdmSoG4ZjhmaZ5Mf0qBi9-0jGVkNw@mail.gmail.com>
References: <1476751442-12112-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Feng Gao <gfree.wind@gmail.com>, Gao Feng <fgao@ikuai8.com>
To: Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:32857 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932415AbcJRA77 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 20:59:59 -0400
Received: by mail-vk0-f68.google.com with SMTP id 83so7823564vkd.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 17:59:59 -0700 (PDT)
In-Reply-To: <1476751442-12112-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 18, 2016 at 8:44 AM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> Use sizeof variable instead of literal number to enhance the readability.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  net/8021q/vlan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 8de138d..5a3903b 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -515,8 +515,8 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
>                 return -EFAULT;
>
>         /* Null terminate this sucker, just in case. */
> -       args.device1[23] = 0;
> -       args.u.device2[23] = 0;
> +       args.device1[sizeof(args.device1) - 1] = 0;
> +       args.u.device2[sizeof(args.u.device2) - 1] = 0;
>
>         rtnl_lock();
>
> --
> 1.9.1
>
>

Sorry, I forget add the "net-next" in the title.
Now I have sent another new patch, please ignore this conversation.

Regards
Feng
