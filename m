From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] textsearch infrastructure et al v2
Date: Wed, 1 Jun 2005 00:44:39 +0200
Message-ID: <20050531224439.GL15391@postel.suug.ch>
References: <20050527224725.GG15391@postel.suug.ch> <20050531.145627.85412348.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050531.145627.85412348.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050531.145627.85412348.davem@davemloft.net> 2005-05-31 14:56
> From: Thomas Graf <tgraf@suug.ch>
> Date: Sat, 28 May 2005 00:47:25 +0200
> 
> > Any other ideas around?
> 
> You could just fetch "windows" of data.
> 
> You can define this window to be 32 bytes, or whatever.

Heh, I had something like this in mind. Well, basically the
current behaviour is not different except that the window
is variable and uses the page data directly rather than
copying.

Back on the static window subject, it would definitely
be helpful for right-to-left scan algorithms such as
boyer-moore. However, I think that the overhead due to
the massive map/unmap and copying is bigger than the
costs of naive searches around the fragment borders.

Pablo joined me on the subject, he's currently working
on converting the fragmentation iteration to use Rusty's
skb_iter code. we'll present new work with some numbers
shortly.
