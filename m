From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] textsearch infrastructure et al v2
Date: Tue, 31 May 2005 14:56:27 -0700 (PDT)
Message-ID: <20050531.145627.85412348.davem@davemloft.net>
References: <20050527224725.GG15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050527224725.GG15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sat, 28 May 2005 00:47:25 +0200

> Any other ideas around?

You could just fetch "windows" of data.

You can define this window to be 32 bytes, or whatever.

Then you use skb_copy_data() into this 32 byte window scratch
pad the text searcher uses, and you're done.  It starts looking
like an MPEG stream parser :-)
