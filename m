From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 -next] net/core/dev: Warn on a too-short GRO frame
Date: Fri, 01 Apr 2016 13:29:30 -0700
Message-ID: <1459542570.6473.291.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459540695-24404-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Joe Perches <joe@perches.com>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33512 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbcDAU3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 16:29:32 -0400
Received: by mail-pf0-f169.google.com with SMTP id 4so98451484pfd.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 13:29:32 -0700 (PDT)
In-Reply-To: <1459540695-24404-1-git-send-email-aconole@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 15:58 -0400, Aaron Conole wrote:
> From: Aaron Conole <aconole@bytheb.org>
> 
> When signaling that a GRO frame is ready to be processed, the network stack
> correctly checks length and aborts processing when a frame is less than 14
> bytes. However, such a condition is really indicative of a broken driver,
> and should be loudly signaled, rather than silently dropped as the case is
> today.
> 
> Convert the condition to use net_warn_ratelimited() to ensure the stack
> loudly complains about such broken drivers.
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> ---


Shouldn't we give a hint of device name ?

(available in napi->dev->name )
