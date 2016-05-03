From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] netdevice: shrink size of struct netdev_queue
Date: Mon, 02 May 2016 18:49:53 -0700
Message-ID: <1462240193.5535.280.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462238949-3271-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:36369 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932455AbcECBuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 21:50:02 -0400
Received: by mail-yw0-f172.google.com with SMTP id o66so6434732ywc.3
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 18:49:56 -0700 (PDT)
In-Reply-To: <1462238949-3271-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-03 at 03:29 +0200, Florian Westphal wrote:
> - trans_timeout is incremented when tx queue timed out (tx watchdog).
> - tx_maxrate is set via sysfs
> 
> Moving tx_maxrate to read-mostly part shrinks the struct by 64 bytes.
> While at it, also move trans_timeout (it is out-of-place in the
> 'write-mostly' part).
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
