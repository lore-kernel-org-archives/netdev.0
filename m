From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH?] Fix sniffing of ARP replies
Date: Fri, 17 Oct 2003 00:10:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031017001013.306f1cd2.davem@redhat.com>
References: <20031015171112.GA2469@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
In-Reply-To: <20031015171112.GA2469@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Oct 2003 19:11:12 +0200
Petr Vandrovec <vandrove@vc.cvut.cz> wrote:

> -		    (struct sock *)ptype->af_packet_priv != skb->sk) {
> +		    (ptype->af_packet_priv == NULL ||
> +		     (struct sock *)ptype->af_packet_priv != skb->sk)) {

Ok, after studying this some more, I think this patch makes
sense and I'll apply it to 2.6.x

Thanks for being patient with my idiocy this afternoon.
:-)
