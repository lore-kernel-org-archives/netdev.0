From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Why is packet socket checked before bridge in
 netif_receive_skb?
Date: Tue, 26 Jul 2005 12:58:36 -0700 (PDT)
Message-ID: <20050726.125836.58466212.davem@davemloft.net>
References: <C86180A8C204554D8A3323D8F6B0A29F6AF010@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: simon@devicescape.com
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F6AF010@dhost002-46.dex002.intermedia.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Simon Barber" <simon@devicescape.com>
Subject: Why is packet socket checked before bridge in netif_receive_skb?
Date: Tue, 26 Jul 2005 11:03:17 -0700

> The protocol handlers are also used to implement packet sockets. - Why
> is the all handler checked before the bridge hook?

Because we want packet sniffers to see the packet before the
bridging layer decapsulates it.
