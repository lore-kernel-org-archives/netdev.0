From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: check the length of the data before dereferencing it
Date: Mon, 2 Apr 2012 12:47:36 +0800
Message-ID: <CABa6K_Hc7ZVVR6XvhEXKHNf_YNnrMNQLBTbxksvAJwAV9fer6w@mail.gmail.com>
References: <1333336250-4110-1-git-send-email-xiaosuo@gmail.com>
 <1333336773.2325.6531.camel@edumazet-glaptop> <20120401.232942.1829187970291547571.davem@davemloft.net>
 <CABa6K_HfWckb=sv7oQatv2ZJm3EKJE0mutQQ-OiddXiR6E7eHg@mail.gmail.com> <1333338797.2325.6610.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1333338797.2325.6610.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 2, 2012 at 11:53 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> No we cant rely on this, kmemcheck might barf on us.
>
> Your patch (and the netfilter one) is fine.
>
>

Got it. Thanks. FYI, the tcp options are copied to the stack before
being parsed.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
