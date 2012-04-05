From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] rps: introduce a new sysctl switch
 rps_workaround_buggy_driver
Date: Thu, 05 Apr 2012 13:07:07 +0200
Message-ID: <1333624027.18626.579.camel@edumazet-glaptop>
References: <4F7D7464.7040503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63399 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694Ab2DELHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 07:07:12 -0400
Received: by eaaq12 with SMTP id q12so395279eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 04:07:11 -0700 (PDT)
In-Reply-To: <4F7D7464.7040503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-05 at 18:31 +0800, Li Yu wrote:
> We encountered a buggy NIC driver or hardware/firmware, it keeps
> non-zero constant skb->rxhash for long time, so if we enabled RPS,
> the targeted CPU keeps same for long time too.
> 
> This patch introduces a sysctl switch to workaround for such problem,
> if the switch was on, RPS core discards the skb->rxhash that is
> computed by NIC hardware.
> 
> Hope this patch also can help others, thanks.

Really ?

to disable this driver rxhash, you should try :

ethtool -K eth0 rxhash off
