From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: keep fragment queues private to each user
Date: Tue, 25 Jan 2005 15:41:04 +0100
Message-ID: <41F65A80.70808@trash.net>
References: <E1CtPJf-0005RG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CtPJf-0005RG-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>However, I think this is still not enough.  What about fragments
>that come from different interfaces? Fragments with different
>security paths?
>
Fragments with different security paths are indeed a problem, I
already tried fixing them by keeping the secpaths of all fragments
on a list in the head secpath and changing __xfrm_policy_check to
deal with them, but it is pretty tricky to get right. For different
interfaces: I'm not exactly sure where this is a problem, except
that any classification will only look at the head fragment interface.

Regards
Patrick
