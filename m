From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Thu, 27 Nov 2003 02:59:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127025921.3fed8dd4.davem@redhat.com>
References: <1069920883.2476.1.camel@teapot.felipe-alfaro.com>
	<20031127.173320.19253188.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: felipe_alfaro@linuxmail.org, linux-kernel@vger.kernel.org,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031127.173320.19253188.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Nov 2003 17:33:20 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> -	strcpy(t->parms.name, dev->name);
> +	strlcpy(t->parms.name, dev->name, IFNAMSIZ);
>                                           sizeof(t->parms.name)
> 
> or something like that.

I agree, using sizeof() is the less error prone way of
doing things like this.

Felipe could you please rewrite your patch like this?

Thank you.
