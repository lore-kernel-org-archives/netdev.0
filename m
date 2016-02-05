From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/7] sock: struct proto hash function may error
Date: Thu, 04 Feb 2016 21:34:03 -0800
Message-ID: <1454650443.7627.298.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
	 <1454600118-30152-2-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33967 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbcBEFeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 00:34:06 -0500
Received: by mail-pf0-f178.google.com with SMTP id o185so62681285pfb.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 21:34:05 -0800 (PST)
In-Reply-To: <1454600118-30152-2-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-04 at 10:35 -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> In order to support fast reuseport lookups in TCP, the hash function
> defined in struct proto must be capable of returning an error code.
> This patch changes the function signature of all related hash functions
> to return an integer and handles or propagates this return value at
> all call sites.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

Acked-by: Eric Dumazet <edumazet@google.com>
