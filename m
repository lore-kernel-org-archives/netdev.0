From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Can we replace the msleep(250) in dev.c  netdev_wait_allrefs?
Date: Tue, 29 Jan 2013 12:21:37 -0800
Message-ID: <1359490897.30177.4.camel@edumazet-glaptop>
References: <51082A64.2090702@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:50788 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab3A2UVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:21:40 -0500
Received: by mail-pb0-f41.google.com with SMTP id ro12so491892pbb.14
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 12:21:39 -0800 (PST)
In-Reply-To: <51082A64.2090702@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-29 at 12:00 -0800, Ben Greear wrote:
> I think there was a proposal to change it to schedule_timeout_uninterruptible(1);
> some time ago, but that change never made it upstream (at least not in 3.7.5)?
> 
> Thanks,
> Ben
> 

Honestly we should fix the bug at this point, not hide it.

We could use msleep(2500) to make sure people will complain ;)
