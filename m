From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/11] [NET] Convert sk_zapped into SOCK_ZAPPED flag
Date: Wed, 09 Mar 2005 20:54:09 +0100
Message-ID: <422F5461.4080008@trash.net>
References: <20050309194521.GH31837@postel.suug.ch> <20050309194711.GJ31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050309194711.GJ31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> -	volatile unsigned char	sk_zapped;
>  	unsigned char		sk_shutdown;
>  	unsigned char		sk_use_write_queue;
>  	unsigned char		sk_userlocks;
> @@ -391,6 +389,7 @@
>  	SOCK_DESTROY,
>  	SOCK_BROADCAST,
>  	SOCK_TIMESTAMP,
> +	SOCK_ZAPPED,

What about volatile ? sock_set_flag() uses __set_bit(), so its not
the same.

Regards
Patrick
