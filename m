From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 7/7] netpoll: avoid kfree_skb on packets with destructo
Date: Thu, 03 Mar 2005 16:17:10 -0500
Message-ID: <42277ED6.4020707@pobox.com>
References: <7.454130102@selenic.com>	<8.454130102@selenic.com> <20050303130031.066f0862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>, netdev@oss.sgi.com, jmoyer@redhat.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050303130031.066f0862.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 03 Mar 2005 14:46:32 -0600
> Matt Mackall <mpm@selenic.com> wrote:
> 
> 
>>Packets that have destructors should not be zapped here as that might
>>produce additional printk warnings via netconsole.
>>
>>Signed-off-by: Matt Mackall <mpm@selenic.com>
> 
> 
> Then where will they be freed, eh? :-)
> 
> This patch adds an SKB leak.  Since you've NULL'd out the list, any
> SKB skipped will never be freed up at all.

Heh, I was just writing this same message.

On a related note...  David, I would prefer if you merged up the netpoll 
stuff, since it touches mainly net/*

Is that cool w/ you?

	Jeff
