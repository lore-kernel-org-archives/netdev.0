From: Dirk Behme <dirk.behme@gmail.com>
Subject: Re: [PATCH 3.14] net: sysctl_net_core: remove compiler warning about
 unused variable 'one'
Date: Tue, 11 Aug 2015 15:54:06 +0200
Message-ID: <55C9FE7E.9050302@gmail.com>
References: <1439296965-5181-1-git-send-email-vladimir_zapolskiy@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Dirk Behme <dirk.behme@de.bosch.com>, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: Vladimir Zapolskiy <vladimir_zapolskiy@mentor.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1439296965-5181-1-git-send-email-vladimir_zapolskiy@mentor.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11.08.2015 14:42, Vladimir Zapolskiy wrote:
> From: Dirk Behme <dirk.behme@de.bosch.com>
>
> Remove the compiler warning
>
>    net/core/sysctl_net_core.c:26:12: warning: 'one' defined but not used [-Wunused-variable]
>       static int one = 1;
>
> introduced by the 3.14.37 stable commit a1d55b36de6bf2 ("net: sysctl_net_core:
> check SNDBUF and RCVBUF for min length") which made 'one' obsolete (in
> contrast to recent mainline kernel, which still uses 'one').
>
> Signed-off-by: Dirk Behme <dirk.behme@de.bosch.com>
> Signed-off-by: Vladimir Zapolskiy <vladimir_zapolskiy@mentor.com>
> Cc: <netdev@vger.kernel.org>
> Cc: <stable@vger.kernel.org> # 3.14.x-
> Fixes: a1d55b36de6b ("net: sysctl_net_core: check SNDBUF and RCVBUF for min length")


It seems that this has been sent previously and was rejected:

http://www.spinics.net/lists/stable/msg87281.html

http://www.spinics.net/lists/stable/msg87282.html

Best regards

Dirk

> ---
>   net/core/sysctl_net_core.c | 1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index e731c96..8725b91 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -23,7 +23,6 @@
>   #include <net/pkt_sched.h>
>
>   static int zero = 0;
> -static int one = 1;
>   static int ushort_max = USHRT_MAX;
>   static int min_sndbuf = SOCK_MIN_SNDBUF;
>   static int min_rcvbuf = SOCK_MIN_RCVBUF;
>
