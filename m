From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Fix suboptimal fragment sizing for last fragment
Date: Tue, 7 Sep 2004 13:35:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907133508.5a7aeafb.davem@redhat.com>
References: <4137681D.3000902@trash.net>
	<20040902144436.2c8c1337.davem@redhat.com>
	<20040902220343.GA3250@gondor.apana.org.au>
	<20040903.104050.29603454.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: herbert@gondor.apana.org.au, kaber@trash.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040903.104050.29603454.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 03 Sep 2004 10:40:50 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In this case, we know we need more fragment(s).
> So, let's fill up to maxfraglen (instead of mtu) 
> to avoid needless copy in the next loop.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Has anyone tested or reviewed this patch?
I'm just walking through my backlog trying
to figure out what I need to spend time on.
