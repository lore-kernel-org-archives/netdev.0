From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: code cleanups
Date: Thu, 30 Sep 2010 11:07:48 +0800
Message-ID: <AANLkTinRm7dB=n7KG8+TU0_=gf-19LUPV+40_m2YxbU2@mail.gmail.com>
References: <1285813497-7384-1-git-send-email-xiaosuo@gmail.com> <1285814979.1866.229.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54780 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab0I3DIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 23:08:10 -0400
Received: by wyb28 with SMTP id 28so1449475wyb.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 20:08:08 -0700 (PDT)
In-Reply-To: <1285814979.1866.229.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 30, 2010 at 10:49 AM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2010-09-30 at 10:24 +0800, Changli Gao wrote:
>> Compare operations are more readable, and compilers generate the same code
>> for the both.
>
> As far as I know, not all supported versions of gcc
> generate the same code.

Is the former better for the compilers?

>
> Also, you could probably now remove the (__force u32) casts.
>

Maybe Eric doesn't think so.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
