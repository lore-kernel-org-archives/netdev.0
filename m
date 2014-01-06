From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] 8021q: make vlan_pcpu_stats visible without CONFIG_VLAN_8021Q
Date: Mon, 6 Jan 2014 09:19:06 +0800
Message-ID: <CAJFZqHymnzNZkQUJYL7j_cvudLGutOcKxz3HUQZvoEA=CfF1DA@mail.gmail.com>
References: <20140106004120.GA32217@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:64838 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbaAFBTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 20:19:08 -0500
Received: by mail-vc0-f177.google.com with SMTP id le5so798746vcb.8
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 17:19:07 -0800 (PST)
In-Reply-To: <20140106004120.GA32217@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 6, 2014 at 8:41 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> macvlan needs vlan_pcpu_stats so make it visible even if compiling
> without VLAN_8021Q support. Otherwise a very long compiler error happens.
>
> Fixes: cdf3e274cf1b36 ("macvlan: unify macvlan_pcpu_stats and vlan_pcpu_stats")
> Cc: Li RongQing <roy.qing.li@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks for fixing this bug

Acked-By: Li RongQing <roy.qing.li@gmail.com>
