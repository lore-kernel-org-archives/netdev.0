From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v4] netpoll: fix a rtnl lock assertion failure
Date: Wed, 16 Jan 2013 20:53:23 -0800
Message-ID: <1358398403.29723.2.camel@edumazet-glaptop>
References: <1358242446-4273-1-git-send-email-amwang@redhat.com>
	 <1358385885.32167.21.camel@edumazet-glaptop> <1358393418.3855.3.camel@cr0>
	 <20130116.225413.1184047803896995845.davem@davemloft.net>
	 <1358396284.3855.16.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jiri@resnulli.us
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:60015 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757587Ab3AQEx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 23:53:26 -0500
Received: by mail-da0-f44.google.com with SMTP id z20so916676dae.3
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 20:53:25 -0800 (PST)
In-Reply-To: <1358396284.3855.16.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-17 at 12:18 +0800, Cong Wang wrote:

> > Why not just... call dev_get_by_name()?  It doesn't hurt to over-RCU
> > lock.
> > 
> 
> Just that taking RCU read lock while having rtnl lock is unnecessary, no
> other reason.

Calling the dev_get_by_name() would be just fine, and generate less
code.

Its not a fast path...

Anyway David already applied your patch.
