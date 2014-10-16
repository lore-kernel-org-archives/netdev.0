From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vxlan: small improvements
Date: Thu, 16 Oct 2014 07:05:35 -0700
Message-ID: <1413468335.28798.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413450045-5008-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:60315 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbaJPOFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 10:05:37 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so3471028pad.22
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 07:05:36 -0700 (PDT)
In-Reply-To: <1413450045-5008-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-16 at 17:00 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 1. remove the dead codes, pr_fmt definition and vxlan_salt variable
> 2. pskb_may_pull() can change skb->data, so we have to reload eth in vxlan_xmit.

I do not see this particular bug in my tree ???

Wait, you added this in a recent commit. Please add

Fixes: 91269e390d062 ("vxlan: using pskb_may_pull as early as possible")

Do not be shy, or hide, try to ease stable teams work, please ?

Thanks.
