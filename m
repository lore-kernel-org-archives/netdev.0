From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 4/5] ifb: add multiqueue support
Date: Wed, 15 Dec 2010 07:34:46 -0500
Message-ID: <1292416486.2067.7.camel@mojatatu>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
	 <1292251414-5154-4-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:52699 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab0LOMet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 07:34:49 -0500
Received: by gxk19 with SMTP id 19so1210707gxk.11
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 04:34:48 -0800 (PST)
In-Reply-To: <1292251414-5154-4-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-13 at 22:43 +0800, Changli Gao wrote:
> Each ifb NIC has nr_cpu_ids rx queues and nr_cpu_ids queues. Packets
> transmitted to ifb are enqueued to the corresponding per cpu tx queues,
> and processed in the corresponding per cpu tasklet latter.
> 
> The stats are converted to the u64 ones.
> 
> tq is a stack variable now. It makes ifb_q_private smaller and tx queue
> locked only once in ri_tasklet.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

I will look closely at this one later and catchup with the discussion
you had with Eric.

cheers,
jamal


