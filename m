From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 iproute2 -next 2/2] ipxfrm: allow to setup filter
 when dumping SA
Date: Fri, 21 Mar 2014 14:25:12 -0700
Message-ID: <20140321142512.28b37940@nehalam.linuxnetplumber.net>
References: <20140320103901.6e57049a@nehalam.linuxnetplumber.net>
	<1395396163-11692-1-git-send-email-nicolas.dichtel@6wind.com>
	<1395396163-11692-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60313 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaCUVZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 17:25:15 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so2925710pbb.33
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 14:25:15 -0700 (PDT)
In-Reply-To: <1395396163-11692-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Mar 2014 11:02:43 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> It's now possible to filter SA directly into the kernel by specifying
> XFRMA_PROTO and/or XFRMA_ADDRESS_FILTER.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> Note that this patch is intended to work with net-next.
> 
> v4: use C99 initializers for all structure
> 
> v3: use C99 initializers
> 
>  ip/xfrm_state.c | 25 ++++++++++++++++++++++++-
>  1 file changed, 24 insertions(+), 1 deletion(-)

Applied to net-next branch
