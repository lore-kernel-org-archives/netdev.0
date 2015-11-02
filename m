From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] af_unix: optimize unix_writable by inlining
Date: Mon, 02 Nov 2015 09:13:46 -0800
Message-ID: <1446484426.23275.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446483719-30310-1-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35519 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932091AbbKBRNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 12:13:47 -0500
Received: by pasz6 with SMTP id z6so154048291pas.2
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 09:13:47 -0800 (PST)
In-Reply-To: <1446483719-30310-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-02 at 12:01 -0500, Aaron Conole wrote:
> unix_writable() originally was inlined, but was changed as part of
> commit 1586a5877db9 ("af_unix: do not report POLLOUT on
> listeners"). Re-enable the inline flag.
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> Cc: Eric Dumazet <edumazet@google.com>
> ---


We leave this to the compiler nowadays.

If you take a look at disassembly, you'll see your patch has no effect
at all.
