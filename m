From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/7] tcp: __tcp_hdrlen() helper
Date: Thu, 04 Feb 2016 21:35:18 -0800
Message-ID: <1454650518.7627.300.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
	 <1454600118-30152-4-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35911 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbcBEFfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 00:35:20 -0500
Received: by mail-pf0-f182.google.com with SMTP id n128so62333802pfn.3
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 21:35:20 -0800 (PST)
In-Reply-To: <1454600118-30152-4-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-04 at 10:35 -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> tcp_hdrlen is wasteful if you already have a pointer to struct tcphdr.
> This splits the size calculation into a helper function that can be
> used if a struct tcphdr is already available.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

Acked-by: Eric Dumazet <edumazet@google.com>
