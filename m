From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: Sun, 25 Jan 2004 21:23:18 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <401425B6.4050701@trash.net>
References: <20040125152419.GA3208@penguin.localdomain> <20040125.112542.10303353.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sebek64@post.cz, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040125.112542.10303353.davem@redhat.com>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: sebek64@post.cz (Marcel Sebek)
>    Date: Sun, 25 Jan 2004 16:24:19 +0100
> 
>    I have ported IMQ driver from 2.4 to 2.6.2-rc1.
>    
>    Original version was from http://trash.net/~kaber/imq/.
>    
> Patrick, do you mind if I merge this 2.6.x port into my tree?
> 

Please don't. The imq device is buggy, it crashes when used
for ingress and egress at the same time, additionally it's
unmaintained since one or two years. The lartc list is full
of bugreports. Some users that depend on the functionality
are working on a better implementation, I'd suggest to wait
until then.

Best regards,
Patrick
