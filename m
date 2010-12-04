From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 04 Dec 2010 09:18:02 -0500
Message-ID: <1291472282.2159.8.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:55231 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755150Ab0LDOXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:23:41 -0500
Received: by gxk19 with SMTP id 19so5655002gxk.11
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:23:41 -0800 (PST)
In-Reply-To: <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-12-04 at 13:55 +0800, Changli Gao wrote:
> tq is only used in ri_tasklet, so we move it from ifb_private to a
> stack variable of ri_tasklet.
> 
> skb_queue_splice_tail_init() is used instead of the open coded and slow
> one.

I like the splice idea but this patch makes me twitch
a little. What test setup did you use to check it?

cheers,
jamal

