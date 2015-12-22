From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next 2/3] tcp: send_reset: test for non-NULL sk first
Date: Tue, 22 Dec 2015 14:05:16 -0500
Message-ID: <1450811116.8474.134.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450729766-14926-1-git-send-email-fw@strlen.de>
	 <1450729766-14926-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33943 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbbLVTFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 14:05:17 -0500
Received: by mail-qg0-f48.google.com with SMTP id 74so70131127qgh.1
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 11:05:17 -0800 (PST)
In-Reply-To: <1450729766-14926-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-21 at 21:29 +0100, Florian Westphal wrote:
> tcp_md5_do_lookup requires a full socket, so once we extend
> _send_reset() to also accept timewait socket we would have to change
> 

Acked-by: Eric Dumazet <edumazet@google.com>
