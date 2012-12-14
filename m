From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH V2] ndisc: Use more standard logging styles
Date: Fri, 14 Dec 2012 05:58:54 -0800
Message-ID: <1355493534.10504.10.camel@edumazet-glaptop>
References: <1355458079.29363.4.camel@joe-AO722>
	 <5f9b97d8b6e1a5e1a4e1d7a3731017bae47fb31d.1355458714.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Duan Jiong <djduanjiong@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5f9b97d8b6e1a5e1a4e1d7a3731017bae47fb31d.1355458714.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-12-13 at 20:23 -0800, Joe Perches wrote:
> The logging style in this file is "baroque".
> 
> Convert indirect uses of net_<level>_ratelimited to
> simply use net_<level>_ratelimited.
> 
> Add a nd_dbg macro and #define ND_DEBUG for the other
> generally inactivated logging messages.
> 
> Make those inactivated messages emit only at KERN_DEBUG
> instead of other levels.  Add "%s: " __func__ to all
> these nd_dbg macros and remove the embedded function
> names and prefixes.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

It seems its not a bug fix, so why are you sending this now ?

Is it so hard to understand the merge window rule ?

net-next is currently closed.
