From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4/2.6 PATCHES] Change some ip_fragment checks to help IPVS
Date: Sat, 11 Oct 2003 12:02:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011120228.74914c91.davem@redhat.com>
References: <Pine.LNX.4.44.0310111956070.31823-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wensong@linux-vs.org, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310111956070.31823-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Oct 2003 20:18:33 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

>  			/* Correct socket ownership. */
> -			if (frag->sk == NULL)
> +			if (frag->sk == NULL && skb->sk)
>  				goto slow_path;

Alexey I think this piece of Julian's patch is OK and this is
the test you meant to make in the first place.

Right?
