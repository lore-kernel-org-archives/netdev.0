From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/7] inet: refactor inet[6]_lookup functions to
 take skb
Date: Thu, 04 Feb 2016 21:36:46 -0800
Message-ID: <1454650606.7627.301.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
	 <1454600118-30152-5-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35131 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbcBEFgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 00:36:48 -0500
Received: by mail-pa0-f44.google.com with SMTP id ho8so28222725pac.2
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 21:36:48 -0800 (PST)
In-Reply-To: <1454600118-30152-5-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-04 at 10:35 -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> This is a preliminary step to allow fast socket lookup of SO_REUSEPORT
> groups.  Doing so with a BPF filter will require access to the
> skb in question.  This change plumbs the skb (and offset to payload
> data) through the call stack to the listening socket lookup
> implementations where it will be used in a following patch.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
