From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH resend] net: sock: Add option for memory optimized hints.
Date: Fri, 17 Jun 2016 07:14:20 -0700
Message-ID: <1466172860.7945.212.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57640204.9070300@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "open list:PTP HARDWARE CLOCK SUPPORT" <netdev@vger.kernel.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33748 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbcFQOOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 10:14:25 -0400
Received: by mail-pa0-f67.google.com with SMTP id ts6so5939263pac.0
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 07:14:24 -0700 (PDT)
In-Reply-To: <57640204.9070300@sonymobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-17 at 15:58 +0200, peter enderborg wrote:
> From: Peter Enderborg <peter.enderborg@sonymobile.com>
> 
> When sending data the socket allocates memory for
> payload on a cache or a page alloc. The page alloc
> then might trigger compation that takes long time.
> This can be avoided with smaller chunks. But
> userspace can not know what is the right size for
> the smaller sends. For this we add a SIZEHINT
> getsocketopt where the userspace can get the size
> for send that will fit into one page (order 0) or
> the max for a slab cache allocation.

For which kind of sockets exactly you hit a problem ?

Sorry, this patch is probably not helping in any way.
