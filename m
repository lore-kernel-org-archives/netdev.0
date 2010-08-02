From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/4] net: check for reference outside of skb
Date: Tue, 3 Aug 2010 07:25:11 +0800
Message-ID: <AANLkTinEC81CYQSVNkbKf4Tgs91=YU9WhiXN3-4LFX_9@mail.gmail.com>
References: <20100802220030.991706005@vyatta.com> <20100802220113.557212477@vyatta.com>
	<AANLkTi=8+xRJn_26740uKuWdgA=XvyB7-hgGT9dxjOXr@mail.gmail.com>
	<20100802162158.0b0c6e70@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51960 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171Ab0HBXZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:25:32 -0400
Received: by wyb39 with SMTP id 39so3813934wyb.19
        for <netdev@vger.kernel.org>; Mon, 02 Aug 2010 16:25:31 -0700 (PDT)
In-Reply-To: <20100802162158.0b0c6e70@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 3, 2010 at 7:21 AM, Stephen Hemminger <shemminger@vyatta.com> wrote:
>
> It should be headroom. It is okay if the request is looking at PAD
> area, that is the callers problem. Just don't want wander off into
> into unallocated space.
>
> Anyway, I'll fix it in cls_u32.
>

FYI: act_pedit may have the same issue. Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
