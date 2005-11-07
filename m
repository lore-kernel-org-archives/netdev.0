From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][MCAST]Clear MAF_GSQUERY flag when process MLDv1 general query
 messages.
Date: Mon, 7 Nov 2005 13:47:23 -0800
Message-ID: <OF7136C7EC.A2BD07E5-ON882570B2.00768CF6-882570B2.0077AB0D@us.ibm.com>
References: <7e77d27c0511070646o7b8686aes@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965164AbVKGVrL@vger.kernel.org>
In-Reply-To: <7e77d27c0511070646o7b8686aes@mail.gmail.com>
To: Yan Zheng <yzcorp@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yan Zheng <yzcorp@gmail.com> wrote on 11/07/2005 06:46:20 AM:

> If the first query message receive after expiration is MLDv2 general
> query and MAF_GSQUERY flag is set. The report message only contains
> sources marked by last MLDv2 Multicast Address and Source Specific
> Queries . Although this circumstance happens  rare, I think it's
> better have it fixed

        Do you have a test case that demonstrates this? It appears to
me that an MLDv2 general query doesn't execute that code (short circuited
above) and an MLDv1 general query (what that code is handling) will
have a timer expiring before switching back to MLDv2 mode (so it'll send
a v1 report, without any sources). Unless I'm missing something, I can't
see any way for the scenario you've described to happen.
        That said, I also can't see anything it would hurt, so I don't 
object,
but it looks unnecessary to me.

                                                        +-DLS
