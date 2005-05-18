From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] TSO Reloaded
Date: Tue, 17 May 2005 23:47:48 -0400
Message-ID: <03e7252e3f5541302f25675360330b1e@psc.edu>
References: <46332e5aa197db91aaf012cf140282b4@psc.edu> <20050517.192829.71087792.davem@davemloft.net> <0dd16bed0ea56242244bab0a7f1cf372@psc.edu> <20050517.200015.55506861.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050517.200015.55506861.davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On May 17, 2005, at 11:00 PM, David S. Miller wrote:

> From: John Heffner <jheffner@psc.edu>
> Date: Tue, 17 May 2005 22:51:53 -0400
>
>> With the new patch I'm getting 78.0%.
>
> Thanks for testing.
>
> I actually expected the new code to do better.
> Splitting could be a little bit expensive, but
> that only occurs at the beginning of the connection
> as we ramp up the congestion and send window.
> Afterwards, we should be able to release full unsplit
> TSO frames onto the wire.

With different (larger than default) buffer sizes, I'm getting 63.4%.  
Not surprising I guess.

   -John
