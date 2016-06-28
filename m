From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: increase size at which tcp_bound_to_half_wnd
 bounds to > TCP_MSS_DEFAULT
Date: Tue, 28 Jun 2016 18:35:44 -0400
Message-ID: <CADVnQy=WG3mbstv1TJEskZHfvKNPzz8HDueYNn3QM0_XG+JQWg@mail.gmail.com>
References: <CS1PR84MB0295E420892A535E40FE338EFD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
 <1467115090.6850.202.camel@edumazet-glaptop3.roam.corp.google.com> <CS1PR84MB02950F38FF1801E89612B9E4FD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Seymour, Shane M" <shane.seymour@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:35716 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbcF1WnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 18:43:02 -0400
Received: by mail-ob0-f170.google.com with SMTP id c3so1305712obc.2
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 15:43:01 -0700 (PDT)
In-Reply-To: <CS1PR84MB02950F38FF1801E89612B9E4FD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 5:54 PM, Seymour, Shane M <shane.seymour@hpe.com> wrote:
>> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
...
>> Anyway, your patch is reversed.
>
> I'm not sure what you mean by reversed, I didn't change the direction
> of the test in the code just what it's being compared against and so
> it's greater than not greater than or equal to.

By reversed, I believe Eric means the following:

Your patch claims that the current line you want to replace says:

-       if (tp->max_window > TCP_MSS_DEFAULT)

And that you want to replace it with this line:

+       if (tp->max_window >= 512)

However, the currrent line is the latter:

   if (tp->max_window >= 512)

And presumably you want to replace it with the former.

It might be best to generate the patch with git.

neal
