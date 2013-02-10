From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH v2 net-next] skbuff: create skb_panic() to let caller
 specify panic
Date: Sun, 10 Feb 2013 16:46:52 -0700
Message-ID: <20130210234651.GD2496@mail.gmail.com>
References: <1360484610-11432-1-git-send-email-sakiwit@gmail.com>
 <20130210182451.GA1602@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:46972 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456Ab3BJXrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 18:47:33 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so2887668pad.9
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 15:47:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130210182451.GA1602@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 10 Feb 2013 19:24:51 +0100
>
> How about to leave skb_under_panic() and skb_over_panic() wrapping
> functions there just to wrap "skb_panic(skb, sz, addr, __func__);" call?
> 
> Seems nice that to state the name in str...

That's really a good idea. If David drops again, I'll implement it.

Thanks a lot,

-- 
Jean Sacren
