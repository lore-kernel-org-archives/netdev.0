From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next] team: refine IFF_XMIT_DST_RELEASE capability
Date: Wed, 18 Jul 2012 20:17:34 +0200
Message-ID: <1342635454.2626.3337.camel@edumazet-glaptop>
References: <1342633178-1411-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56186 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755353Ab2GRSRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:17:39 -0400
Received: by yhmm54 with SMTP id m54so1879718yhm.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 11:17:38 -0700 (PDT)
In-Reply-To: <1342633178-1411-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 19:39 +0200, Jiri Pirko wrote:
> Cloned patch of Eric Dumazet for bonding.
> 
> Some workloads greatly benefit of IFF_XMIT_DST_RELEASE capability
> on output net device, avoiding dirtying dst refcount.
> 
> team currently disables IFF_XMIT_DST_RELEASE unconditionally.
> 
> If all ports have the IFF_XMIT_DST_RELEASE bit set, then
> team dev can also have it in its priv_flags.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/team/team.c |    5 +++++
>  1 file changed, 5 insertions(+)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
