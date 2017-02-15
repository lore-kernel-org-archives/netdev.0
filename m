From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: net/xfrm: stack out-of-bounds in xfrm_flowi_sport
Date: Wed, 15 Feb 2017 07:26:22 +0100
Message-ID: <20170215062622.GO30338@gauss.secunet.com>
References: <CACT4Y+ZBY+gYUJ9NuxPByEbbrR7M09vBd5Lx4=xGSGXSxai==Q@mail.gmail.com>
 <20170214070854.GH30338@gauss.secunet.com>
 <CACT4Y+aPd8drh7MQf8cXLs_9f-oymf6YiWfN+owUsSYYz0yMzA@mail.gmail.com>
 <20170214090816.GJ30338@gauss.secunet.com>
 <CACT4Y+a7-TXY2f14Cn0wUapiJ5BYv=2wkJ4vcMGMnbDjqTPnVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+a7-TXY2f14Cn0wUapiJ5BYv=2wkJ4vcMGMnbDjqTPnVw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 14, 2017 at 10:16:44AM +0100, Dmitry Vyukov wrote:
> 
> I've run the repro with you patch and don't see the bug any more:
> 
> Tested-by: Dmitry Vyukov <dvyukov@google.com>

I've applied this to the ipsec tree now.

Thanks for testing!
