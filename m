From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: [PATCH -mm] __ratelimit rewrite
Date: Sun, 4 May 2008 16:13:18 +0800
Message-ID: <a8e1da0805040113n59155fa7y7e0a016afca8ee86@mail.gmail.com>
References: <20080504070738.GA11832@darkstar.te-china.tietoenator.com>
	 <20080504.005433.98511912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, paulmck@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.251]:22665 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbYEDINS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 04:13:18 -0400
Received: by ag-out-0708.google.com with SMTP id 31so1213965agc.10
        for <netdev@vger.kernel.org>; Sun, 04 May 2008 01:13:18 -0700 (PDT)
In-Reply-To: <20080504.005433.98511912.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 4, 2008 at 3:54 PM, David Miller <davem@davemloft.net> wrote:
> From: Dave Young <hidave.darkstar@gmail.com>
>  Date: Sun, 4 May 2008 15:07:38 +0800
>
>  Hi Dave,
>
>
>  > @@ -76,8 +76,8 @@ extern void warn_on_slowpath(const char
>  >       unlikely(__ret_warn_once);                              \
>  >  })
>  >
>  > -#define WARN_ON_SECS(condition, state, secs)                 \
>  > -             WARN_ON((condition) && __ratelimit(state))
>  > +#define WARN_ON_RATELIMIT(condition, state)                  \
>  > +             WARN_ON((condition) && __ratelimit(state));
>  >
>  >  #ifdef CONFIG_SMP
>  >  # define WARN_ON_SMP(x)                      WARN_ON(x)
>
>  Are you sure you want that new semicolon there?

David, thanks for your review. Will fix.

>
>         if (foo)
>                 WARN_ON_RATELIMIT(...);
>         else
>
>  will result in a compile error.
>
