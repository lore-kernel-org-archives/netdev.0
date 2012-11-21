From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH]ipv6:  fix the bug when we do not have a socket context
Date: Wed, 21 Nov 2012 06:40:57 -0800
Message-ID: <1353508857.2590.29.camel@edumazet-glaptop>
References: <50ACB71C.4080101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <djduanjiong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:58763 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809Ab2KUOlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 09:41:00 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so5072472iay.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 06:40:59 -0800 (PST)
In-Reply-To: <50ACB71C.4080101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 19:12 +0800, Duan Jiong wrote:
> call the ip6_update_pmtu/ip6_redirect function to deal with
> ICMPV6 Error Messages and Redirect Message, when we do not
> have a socket context.
> 
> Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
> ---

What is the exact problem you want to solve ?

What is the possible impact on the routing table size ?

Thanks
