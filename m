From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: Use kmemdup instead of kmalloc
	and memcpy
Date: Mon, 27 Jun 2016 09:59:36 -0400 (EDT)
Message-ID: <20160627.095936.2017216616383106273.davem@davemloft.net>
References: <20160623044937.GA14109@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr,
	tipc-discussion@lists.sourceforge.net
To: amitoj1606@gmail.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20160623044937.GA14109@amitoj-Inspiron-3542>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Thu, 23 Jun 2016 10:19:37 +0530

> Replace calls to kmalloc followed by a memcpy with a direct call to
> kmemdup.
> 
> The Coccinelle semantic patch used to make this change is as follows:
> @@
> expression from,to,size,flag;
> statement S;
> @@
> 
> -  to = \(kmalloc\|kzalloc\)(size,flag);
> +  to = kmemdup(from,size,flag);
>    if (to==NULL || ...) S
> -  memcpy(to, from, size);
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied.

------------------------------------------------------------------------------
Attend Shape: An AT&T Tech Expo July 15-16. Meet us at AT&T Park in San
Francisco, CA to explore cutting-edge tech and listen to tech luminaries
present their vision of the future. This family event has something for
everyone, including kids. Get more information and register today.
http://sdm.link/attshape
