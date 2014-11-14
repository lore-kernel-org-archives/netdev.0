From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/1 net-next] openvswitch: use PTR_ERR_OR_ZERO
Date: Fri, 14 Nov 2014 12:34:06 -0800
Message-ID: <CALnjE+p1GaoCnvk_KVZu--Gmf=CK=TbmWjbpN=LqQk==dRCJMg@mail.gmail.com>
References: <1415989978-28559-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:38754 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1161771AbaKNUeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 15:34:07 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so1797767ier.18
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 12:34:06 -0800 (PST)
In-Reply-To: <1415989978-28559-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 10:32 AM, Fabian Frederick <fabf@skynet.be> wrote:
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>  net/openvswitch/flow_netlink.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c0d066d..c8fccdd 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -1425,10 +1425,8 @@ static int add_action(struct sw_flow_actions **sfa, int attrtype,
>         struct nlattr *a;
>
>         a = __add_action(sfa, attrtype, data, len, log);
> -       if (IS_ERR(a))
> -               return PTR_ERR(a);
>
> -       return 0;
> +       return PTR_ERR_OR_ZERO(a);
>  }
>
>  static inline int add_nested_action_start(struct sw_flow_actions **sfa,
> --
> 1.9.3
>
