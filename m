From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [NET] Save space for sk_alloc_slab() failure message.
Date: Thu, 17 Mar 2005 10:31:06 -0800
Message-ID: <20050317103106.009e6b2a.davem@davemloft.net>
References: <20050318.033039.116005935.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050318.033039.116005935.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 03:30:39 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> (Almost) all callers of sk_alloc_slab() handle its failure like this:
> 
>   if (sk_alloc_slab(&prot, "sock")) {
>     sk_alloc_slab_error(&prot);	/* except for sctp */
>     goto out;
>   }
> 
> So, why don't we move sk_alloc_slab_error() into sk_alloc_slab()
> for simplification and save text segment?
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Looks great, patch applied.

Thanks.
