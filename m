From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan: unnecessary to check if vlan_pcpu_stats is NULL
Date: Thu, 03 Apr 2014 14:01:06 -0700
Message-ID: <1396558866.12330.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396529125-1441-1-git-send-email-roy.qing.li@gmail.com>
	 <20140403.163603.2057792710871114160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:43469 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbaDCVBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 17:01:08 -0400
Received: by mail-pa0-f42.google.com with SMTP id fb1so2436386pad.29
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 14:01:07 -0700 (PDT)
In-Reply-To: <20140403.163603.2057792710871114160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-03 at 16:36 -0400, David Miller wrote:
> From: roy.qing.li@gmail.com
> Date: Thu,  3 Apr 2014 20:45:25 +0800
> 
> > From: Li RongQing <roy.qing.li@gmail.com>
> > 
> > if allocating memory for vlan_pcpu_stats failed, the device can not be operated
> > 
> > Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> 
> This check seems to have been there since Eric Dumazet added precise
> RX statistic accounting.
> 
> It looks unnecessary to me, Eric?

Right, this patch seems fine, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
