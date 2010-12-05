From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3 v2] ifb: use the lockless variants of skb_queue
Date: Sun, 05 Dec 2010 09:26:20 -0500
Message-ID: <1291559180.2159.683.camel@mojatatu>
References: <1291510912-6979-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jarek Poplawski <jarkao2@gmail.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:56302 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982Ab0LEO0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 09:26:36 -0500
Received: by yxt3 with SMTP id 3so5054096yxt.19
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 06:26:35 -0800 (PST)
In-Reply-To: <1291510912-6979-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-12-05 at 09:01 +0800, Changli Gao wrote:
> rq and tq are both protected by tx queue lock, so we can simply use
> the lockless variants of skb_queue.
> 
> skb_queue_splice_tail_init() is used instead of the open coded and slow
> one.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

