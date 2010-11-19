From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: reduce the lines of code
Date: Fri, 19 Nov 2010 15:17:34 +0800
Message-ID: <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com> <b2c34db84e88366e465af590900ae3db@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41798 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304Ab0KSHR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 02:17:56 -0500
Received: by fxm13 with SMTP id 13so411851fxm.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 23:17:55 -0800 (PST)
In-Reply-To: <b2c34db84e88366e465af590900ae3db@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 2:35 PM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
>
> On Fri, 19 Nov 2010 10:04:44 +0800, Changli Gao <xiaosuo@gmail.com> wrote:
>> Use macros to reduce the regularity lines.
>
> This is complete awkward and does not fix anything - on the contrary it
> makes it harder to understand the code and no advantage is achieved.
>

Although it doesn't fix anything, It can simplify the adding of new
BPF instructions, one place in filter_def.h instead of two in
filter.c. I think if some code can be generated automatically, we'd
better not write it manually, as the chance of error is less when the
code is generated automatically.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
