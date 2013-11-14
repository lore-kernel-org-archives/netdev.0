From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: softirq lockdep trace when ethernet (tg3) brought up.
Date: Thu, 14 Nov 2013 11:41:43 -0800
Message-ID: <1384458103.28716.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131114191621.GB9630@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:48223 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646Ab3KNTrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 14:47:37 -0500
Received: by mail-yh0-f49.google.com with SMTP id z6so1271681yhz.8
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 11:47:35 -0800 (PST)
In-Reply-To: <20131114191621.GB9630@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 14:16 -0500, Dave Jones wrote:
> See this during boot on one of my test boxes:
> Not sure why it only shows up on that machine. TG3 specific ?

Not tg3 specific, 32bit arches specific ;)

Thanks for the report, I'll take a look.
