From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Namespaceify tcp_fastopen knob
Date: Tue, 12 Sep 2017 20:57:09 -0700 (PDT)
Message-ID: <20170912.205709.130426973112637232.davem@davemloft.net>
References: <1505212257-13386-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505212257-13386-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Tue, 12 Sep 2017 18:30:57 +0800

> Different namespace application might require enable TCP Fast Open
> feature independently of the host.
> 
> Reported-by: Luca BRUNO <lucab@debian.org>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
 ...
> diff --git a/samples/bpf/test_ipip.sh b/samples/bpf/test_ipip.sh
> index 1969254..7bbc521 100755
> --- a/samples/bpf/test_ipip.sh
> +++ b/samples/bpf/test_ipip.sh
> @@ -173,6 +173,8 @@ function cleanup {
>  cleanup
>  echo "Testing IP tunnels..."
>  test_ipip
> +sleep 1
>  test_ipip6
> +sleep 1
>  test_ip6ip6
>  echo "*** PASS ***"

This seems like a completely unrelated change.
