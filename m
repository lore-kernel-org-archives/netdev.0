From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/11] [NET] Convert sk_zapped into SOCK_ZAPPED flag
Date: Wed, 9 Mar 2005 20:56:49 +0100
Message-ID: <20050309195649.GT31837@postel.suug.ch>
References: <20050309194521.GH31837@postel.suug.ch> <20050309194711.GJ31837@postel.suug.ch> <422F5461.4080008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <422F5461.4080008@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <422F5461.4080008@trash.net> 2005-03-09 20:54
> Thomas Graf wrote:
> >-	volatile unsigned char	sk_zapped;
> > 	unsigned char		sk_shutdown;
> > 	unsigned char		sk_use_write_queue;
> > 	unsigned char		sk_userlocks;
> >@@ -391,6 +389,7 @@
> > 	SOCK_DESTROY,
> > 	SOCK_BROADCAST,
> > 	SOCK_TIMESTAMP,
> >+	SOCK_ZAPPED,
> 
> What about volatile ? sock_set_flag() uses __set_bit(), so its not
> the same.

I thought about this for a while but couldn't find a reason
why it shouldn't work. Actually I don't even see any reason for
having sk_zapped be volatile.
