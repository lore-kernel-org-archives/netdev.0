From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] build: unbreak linkage of m_xt.so
Date: Sun, 16 Dec 2012 05:30:50 -0500
Message-ID: <50CDA2DA.3060805@mojatatu.com>
References: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr> <1355617968-26138-1-git-send-email-jengelh@inai.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, vapier@gentoo.org,
	netdev@vger.kernel.org, urykhy@gmail.com, shemonc@gmail.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:61877 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378Ab2LPKax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 05:30:53 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so4583316iay.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 02:30:53 -0800 (PST)
In-Reply-To: <1355617968-26138-1-git-send-email-jengelh@inai.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-15 07:32 PM, Jan Engelhardt wrote:
> Commit v3.7.0~10 caused the variable new PKG_CONFIG variable never
> to be present at the time of calling make, leading to tc/m_xt.so
> not linked with -lxtables (result from pkg-config xtables --libs),
> that in turn leading to
>
> tc: symbol lookup error: /usr/lib64/tc//m_xt.so: undefined symbol:
> xtables_init_all
>

Yep - run into this problem, scratching my head thinking something
wrong with my environment with latest iproute2 git tree. I hacked
mine to just always include xtables in LDLIBS.

> Fixing that.
>
> Signed-off-by: Jan Engelhardt <jengelh@inai.de>

I can confirm it builds fine for me now if i take out the hack I had and 
use this patch.
Acked-by: Jamal Hadi Salim <hadi@mojatatu.com>

Stephen, I think this patch would be equivalent of "stable fix".

cheers,
jamal
