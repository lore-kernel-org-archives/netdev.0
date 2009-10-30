From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder Cookie
Date: Fri, 30 Oct 2009 14:11:54 -0400
Message-ID: <4AEB2C6A.50900@gmail.com>
References: <4AEAC763.4070200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:61851 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932799AbZJ3SLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:11:55 -0400
Received: by mail-bw0-f227.google.com with SMTP id 27so3871404bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 11:11:59 -0700 (PDT)
In-Reply-To: <4AEAC763.4070200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> First of all, this is my first attempt at locks, so I'd like early review.
> 
> Secondly, scripts/checkpatch.pl tells me:
> 
> ERROR: do not initialise statics to 0 or NULL
> #95: FILE: net/ipv4/tcp.c:2977:
> +static struct tcp_cookie_secret *tcp_secret_generating = NULL;
> 
> They need to be NULL, and I'm not planning on exporting them, so what's
> the preferred mechanism?
> 
> (I've grep'd many other instances of statics = 0 or NULL, so I'm not 
> alone.)
> 
I've found a void __init tcp_init() that seems to be used to initialize
some things, so I've stuck the NULL in there.

Still would like somebody to assure me that I've used the locks correctly.

