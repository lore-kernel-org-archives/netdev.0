From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: [SKBUFF] introduce skb_link_header_size(skb)
Date: Tue, 5 Oct 2004 21:33:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005193352.GA19714@rei.reeler.org>
References: <4162F28B.2050308@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <4162F28B.2050308@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Arnaldo Carvalho de Melo <4162F28B.2050308@conectiva.com.br> 2004-10-05 16:14
> +static inline int skb_link_header_size(const struct sk_buff *skb)
> +{
> +	return skb->nh.raw - skb->mac.raw;
> +}

The patch is valid and I think it is right to do so but this may lead to
wrong results when skb->mac.raw is set to 0x0 F.e in classifiers. Maybe
add a comment to warn about it?
