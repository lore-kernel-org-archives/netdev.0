From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/7] inet: create IPv6-equivalent inet_hash
 function
Date: Thu, 04 Feb 2016 21:34:55 -0800
Message-ID: <1454650495.7627.299.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
	 <1454600118-30152-3-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33381 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbcBEFe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 00:34:57 -0500
Received: by mail-pf0-f172.google.com with SMTP id w123so63031751pfb.0
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 21:34:56 -0800 (PST)
In-Reply-To: <1454600118-30152-3-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-04 at 10:35 -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> In order to support fast lookups for TCP sockets with SO_REUSEPORT,
> the function that adds sockets to the listening hash set needs
> to be able to check receive address equality.  Since this equality
> check is different for IPv4 and IPv6, we will need two different
> socket hashing functions.
> 
> This patch adds inet6_hash identical to the existing inet_hash function
> and updates the appropriate references.  A following patch will
> differentiate the two by passing different comparison functions to
> __inet_hash.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

Acked-by: Eric Dumazet <edumazet@google.com>
