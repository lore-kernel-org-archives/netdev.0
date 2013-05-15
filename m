From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/802/mrp: fix lockdep splat
Date: Wed, 15 May 2013 08:22:05 -0700
Message-ID: <1368631325.4519.30.camel@edumazet-glaptop>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
	 <1368447851.13473.119.camel@edumazet-glaptop>
	 <16b0a5ee4602cb9005dd67ea7ad0d4e8@visp.net.lb>
	 <20130514.120754.1745967383330029903.davem@davemloft.net>
	 <1368559307.4519.21.camel@edumazet-glaptop>
	 <1368560401.4519.25.camel@edumazet-glaptop>
	 <1851d9143b2404f6686cf25d6bcea823@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, amwang@redhat.com,
	david.ward@ll.mit.edu, hayeswang@realtek.com, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:56653 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758243Ab3EOPWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 11:22:09 -0400
Received: by mail-pb0-f48.google.com with SMTP id md4so1466936pbc.35
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 08:22:09 -0700 (PDT)
In-Reply-To: <1851d9143b2404f6686cf25d6bcea823@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 17:50 +0300, Denys Fedoryshchenko wrote:
> On 2013-05-14 22:40, Eric Dumazet wrote:
> > 
> > I definitely could trigger the bug easily without my patch :
> 
> 
> > 
> > And with the patch, there is no lockdep splat anymore.
> > 
> > Tested-by: Eric Dumazet <edumazet@google.com>
> 
> Yes, it seems after depclean i cannot reproduce anymore this bug. My 
> bad, seems i should recompile kernel completely next time.
> 

Thanks for testing again, I was quite mystified by your original
results ;)
