From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [SKBUFF] introduce tr_hdr(skb)
Date: Wed, 6 Oct 2004 12:16:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006121648.4c5c3994.davem@davemloft.net>
References: <41643C40.8070605@conectiva.com.br>
	<20041006185835.GB19714@rei.reeler.org>
	<4164424E.6000504@conectiva.com.br>
	<41644519.6040405@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, tgraf@suug.ch, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41644519.6040405@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 06 Oct 2004 16:18:49 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> You're right, if tr_source_route is called, skb->mac.raw has to be set
> to skb->data, to maintain the old behaviour, if it is right?

Yep.
