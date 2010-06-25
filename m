From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v3] act_mirred: don't clone skb when skb isn't shared
Date: Fri, 25 Jun 2010 08:39:11 -0400
Message-ID: <1277469551.5438.0.camel@bigi>
References: <1277432712-2869-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:32842 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610Ab0FYMjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 08:39:18 -0400
Received: by vws9 with SMTP id 9so3844976vws.19
        for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 05:39:15 -0700 (PDT)
In-Reply-To: <1277432712-2869-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-06-25 at 10:25 +0800, Changli Gao wrote:
> don't clone skb when skb isn't shared
> 
> When the tcf_action is TC_ACT_STOLEN, and the skb isn't shared, we don't need
> to clone a new skb. As the skb will be freed after this function returns, we
> can use it freely once we get a reference to it.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>


cheers,
jamal

