From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH net-next v2 0/2] 6lowpan: code updates
Date: Thu, 17 May 2012 11:31:34 +0400
Message-ID: <CAJmB2rAVwSNmkjFWuZBgDVMLKa=T3H5TwoEYHxfMnDecSgGsmA@mail.gmail.com>
References: <1337153248-5779-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<20120516.152801.915753046212672140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:34811 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759523Ab2EQHbf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 03:31:35 -0400
Received: by lahd3 with SMTP id d3so1095984lah.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 00:31:34 -0700 (PDT)
In-Reply-To: <20120516.152801.915753046212672140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Got it!

Damn, my fault, sorry for that.

Alex

2012/5/16 David Miller <davem@davemloft.net>:
> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> Date: Wed, 16 May 2012 11:27:26 +0400
>
>> =A0 6lowpan: rework data fetching from skb
>
> This is not what we told you to do.
>
> We told you that IF you were going to emit a warning message
> for the pskb_may_pull() failure condition, you should use
> WARN_ON_ONCE() so that it doesn't potentially flood the
> logs.
>
> But you must always, in every case, handle the error in some
> reasonable way, not just when WARN_ON_ONCE() does that initial
> one-and-only trigger.
