From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 1/1 net-next] netlabel: kernel-doc warning fix
Date: Tue, 07 Oct 2014 18:13:34 -0400
Message-ID: <18856194.K9PbrNbEaI@sifl>
References: <1412713892-5537-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412713892-5537-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, October 07, 2014 10:31:32 PM Fabian Frederick wrote:
> no secid argument in netlbl_cfg_unlbl_static_del
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Thanks.  Likely a copy/paste error from netlbl_cfg_unlbl_static_add().

Acked-by: Paul Moore <paul@paul-moore.com>

> ---
>  net/netlabel/netlabel_kapi.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
> index 0b4692d..a845cd4 100644
> --- a/net/netlabel/netlabel_kapi.c
> +++ b/net/netlabel/netlabel_kapi.c
> @@ -246,7 +246,6 @@ int netlbl_cfg_unlbl_static_add(struct net *net,
>   * @addr: IP address in network byte order (struct in[6]_addr)
>   * @mask: address mask in network byte order (struct in[6]_addr)
>   * @family: address family
> - * @secid: LSM secid value for the entry
>   * @audit_info: NetLabel audit information
>   *
>   * Description:

-- 
paul moore
www.paul-moore.com
