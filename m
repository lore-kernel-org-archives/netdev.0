From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH] skbuff: create skb_panic() to let caller specify panic
Date: Sat, 9 Feb 2013 23:40:24 -0700
Message-ID: <20130210064024.GC2496@mail.gmail.com>
References: <1360471749-6177-1-git-send-email-sakiwit@gmail.com>
 <1360473061.26127.1.camel@joe-AO722>
 <20130210055629.GB2496@mail.gmail.com>
 <1360476173.26127.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:50424 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab3BJGlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 01:41:04 -0500
Received: by mail-pb0-f51.google.com with SMTP id un15so297845pbc.24
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 22:41:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360476173.26127.3.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 09 Feb 2013 22:02:53 -0800
>
> On Sat, 2013-02-09 at 22:56 -0700, Jean Sacren wrote:
> > From: Joe Perches <joe@perches.com>
> > > Don't split the format across multiple lines please.
> []
> > Honestly I didn't want to split the whole string, but I was in the
> > dilemma of accommodating 80-column convention. I'm ready to respin if
> > the consensus favors one long string. But how long is too long?
> 
> Documentation/CodingStyle
> 
> 		Chapter 2: Breaking long lines and strings
> ...
> never break user-visible strings such as printk messages,
> because that breaks the ability to grep for them

I appreciate you for sharing this document with me, but this scenario is
unique, as it concerns panic. Under this circumstance, are we able to
grep?

-- 
Jean Sacren
