From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: use reciprocal divide
Date: Fri, 19 Nov 2010 16:18:05 +0800
Message-ID: <AANLkTi=qR==8g2Z_GeAOsczVmUS3yj1PnsOfoU7zbudG@mail.gmail.com>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
 <b2c34db84e88366e465af590900ae3db@localhost> <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
 <1290153111.29509.2.camel@edumazet-laptop> <1290153398.29509.7.camel@edumazet-laptop>
 <1290153886.29509.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63724 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab0KSIS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 03:18:28 -0500
Received: by fxm13 with SMTP id 13so440695fxm.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 00:18:27 -0800 (PST)
In-Reply-To: <1290153886.29509.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 4:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> At compile time, we can replace the DIV_K instruction (divide by a
> constant value) by a reciprocal divide.
>
> At exec time, the expensive divide is replaced by a multiply, a less
> expensive operation on most processors.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Changli Gao <xiaosuo@gmail.com>


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
