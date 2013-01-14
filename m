From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v3] netpoll: fix a rtnl lock assertion failure
Date: Mon, 14 Jan 2013 09:09:56 -0800
Message-ID: <1358183396.8744.3100.camel@edumazet-glaptop>
References: <1358160234-24996-1-git-send-email-amwang@redhat.com>
	 <1358183252.8744.3094.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:37702 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757640Ab3ANRKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 12:10:02 -0500
Received: by mail-pb0-f49.google.com with SMTP id un15so2256684pbc.8
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 09:10:01 -0800 (PST)
In-Reply-To: <1358183252.8744.3094.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-14 at 09:07 -0800, Eric Dumazet wrote:

> Strange, why dont we call netdev_master_upper_dev_get() instead ?
> 
> 

What I meant is : the result of this check might be of little use, if we
don't hold any lock preventing another thread to change things behind
us.
