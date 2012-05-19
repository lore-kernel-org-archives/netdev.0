From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tg3: use netdev_alloc_frag() API
Date: Sat, 19 May 2012 10:17:31 +0200
Message-ID: <1337415451.7029.94.camel@edumazet-glaptop>
References: <1337411749.7029.77.camel@edumazet-glaptop>
	 <20120519.031914.1744866102736414778.davem@davemloft.net>
	 <1337412701.7029.79.camel@edumazet-glaptop>
	 <20120519.040101.508727755785767140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58426 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab2ESIRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 04:17:36 -0400
Received: by bkcji2 with SMTP id ji2so2881903bkc.19
        for <netdev@vger.kernel.org>; Sat, 19 May 2012 01:17:34 -0700 (PDT)
In-Reply-To: <20120519.040101.508727755785767140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-19 at 04:01 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 19 May 2012 09:31:41 +0200
> 
> > Indeed, there is an extra space at the end of one line in my tree... ???
> > 
> > atomic_add((PAGE_SIZE / TG3_FRAGSIZE) - 1, &page->_count); <HERE>
> 
> I silently fix trailing whitespace errors in your patches.

OK, good to know ;)
