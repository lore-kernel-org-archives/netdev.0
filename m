From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 1/2] net/core: Add netlink directives to control VF
 link state
Date: Wed, 08 May 2013 20:02:03 +0400
Message-ID: <518A76FB.5030704@cogentembedded.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com> <1368020717-22194-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:58507 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756849Ab3EHQCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 12:02:02 -0400
Received: by mail-lb0-f176.google.com with SMTP id v20so2083720lbc.7
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 09:02:00 -0700 (PDT)
In-Reply-To: <1368020717-22194-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08-05-2013 17:45, Or Gerlitz wrote:

> From: Rony Efraim <ronye@mellanox.com>

> Auto -	the VF link state will reflect the PF link state
>
> Enable - VF link stat will be always up, traffic from VF to VF can
> 	 work even if PF link is down.
>
> Disable - VF link state is down and the VF can't send/recv, e.g can be
>    	  used to suspend the link while configuring the VF.

> Signed-off-by: Rony Efraim <ronye@mellanox.com>

[...]

> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index a08bd2b..bec44a3 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1238,6 +1238,15 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
>   							       ivs->setting);
>   			break;
>   		}
> +		case IFLA_VF_LINK_STATE: {
> +			struct ifla_vf_link_state *ivl;
> +			ivl = nla_data(vf);

     Why not make it initializer? And empty line is needed between the 
declaration and other code.

WBR, Sergei
