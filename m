From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: core: Fix race by  protecting process_queues at
 CPU hotplug
Date: Wed, 14 Jan 2015 23:01:22 -0800
Message-ID: <1421305282.11734.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:55315 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbbAOHBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 02:01:24 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so13129722iga.0
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 23:01:23 -0800 (PST)
In-Reply-To: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 03:13 +0000, subashab@codeaurora.org wrote:
> I am seeing frequent crashes in high throughput conditions in a
> multiprocessor system with kernel version 3.10 where cores are getting hot
> plugged. I have pinned the network stack to a particular core using
> receive packet steering (RPS). At the time of crash, it looks like a
> contention of the process_queue between dev_cpu_callback and
> process_backlog.

Your patch is mangled, hard to tell what is going on.
