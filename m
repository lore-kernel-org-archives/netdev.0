From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] fix ip_gre lockless xmits
Date: Thu, 26 Jan 2012 16:50:40 -0500
Message-ID: <CA+FuTSdXCi-iHGw-3cHX0aD+VYw0C7GmxKHJucimF9C7h-CzeA@mail.gmail.com>
References: <1327610075-5833-1-git-send-email-willemb@google.com> <1327611491.4140.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:62079 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754025Ab2AZVvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 16:51:12 -0500
Received: by lagu2 with SMTP id u2so601678lag.19
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2012 13:51:10 -0800 (PST)
In-Reply-To: <1327611491.4140.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ip link add gre34 type gre remote 1.2.3.4
>
> I was not aware of the "ip tunnel add ..."

And I was unaware of that method. Interesting. That explains the
alternative codepath in rtnetlink.c. `ip link help` does not mention
gre or gretap on its list of supported types, even though they work.
Thanks for having a look!
