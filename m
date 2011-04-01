From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: Re: [Bridge] [PATCH] net/bridge: Fix wrong return-no-vaule
Date: Fri, 1 Apr 2011 23:41:23 +0530
Message-ID: <AANLkTikH6M5f479PnWL-V-C3uF7Qcm79P1+eDizWasyV@mail.gmail.com>
References: <1301631861-12470-1-git-send-email-namei.unix@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@linux-foundation.org, davem@davemloft.net,
	"open list:ETHERNET BRIDGE" <netdev@vger.kernel.org>,
	Liu Yuan <tailai.ly@taobao.com>,
	"open list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>,
	open list <linux-kernel@vger.kernel.org>
To: namei.unix@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301631861-12470-1-git-send-email-namei.unix@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is already fixed and applied

On 4/1/11, namei.unix@gmail.com <namei.unix@gmail.com> wrote:
> From: Liu Yuan <tailai.ly@taobao.com>
>
> In br_stp_if.c/br_stp_recalculate_bridge_id, it should return
> false, which indicates that there is no change when we find
> that user has chosen a value.
>
> Signed-off-by: Liu Yuan <tailai.ly@taobao.com>
> ---
>  net/bridge/br_stp_if.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 5593f5a..9b61d09 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -213,7 +213,7 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
>
>  	/* user has chosen a value so keep it */
>  	if (br->flags & BR_SET_MAC_ADDR)
> -		return;
> +		return false;
>
>  	list_for_each_entry(p, &br->port_list, list) {
>  		if (addr == br_mac_zero ||
> --
> 1.7.1
>
> _______________________________________________
> Bridge mailing list
> Bridge@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/bridge
>
