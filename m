From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/1] openvswitch: Remove unnecessary version.h inclusion
Date: Fri, 9 Jan 2015 10:00:16 -0800
Message-ID: <CALnjE+q6Q4wezbQbY9W_+4N8NLZSZSt0w4VxCBFDpPKAoS5wZg@mail.gmail.com>
References: <1420815381-29973-1-git-send-email-s.syam@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	syamsidhardh <syamsidhardh@gmail.com>,
	David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Syam Sidhardhan <s.syam@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:59708 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750939AbbAISA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 13:00:28 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so16278205ieb.3
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 10:00:17 -0800 (PST)
In-Reply-To: <1420815381-29973-1-git-send-email-s.syam@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 6:56 AM, Syam Sidhardhan <s.syam@samsung.com> wrote:
> version.h inclusion is not necessary as detected by versioncheck.
>
> Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>

You should use net-next prefix flag for net-next tree patches.
Otherwise looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>  net/openvswitch/vport-geneve.c |    2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
> index 347fa23..70e2aae 100644
> --- a/net/openvswitch/vport-geneve.c
> +++ b/net/openvswitch/vport-geneve.c
> @@ -9,8 +9,6 @@
>
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>
> -#include <linux/version.h>
> -
>  #include <linux/in.h>
>  #include <linux/ip.h>
>  #include <linux/net.h>
> --
> 1.7.9.5
>
