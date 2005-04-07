From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] RTNETLINK: Protocol family wildcard dumping for
	routing rules
Date: 07 Apr 2005 19:13:36 -0400
Message-ID: <1112915616.1089.27.camel@jzny.localdomain>
References: <20050407213838.GW26731@postel.suug.ch>
	 <E1DJfBR-0007Ym-00@gondolin.me.apana.org.au>
	 <20050407223847.GX26731@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050407223847.GX26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-04-07 at 18:38, Thomas Graf wrote:
> -	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      }
> +	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      },
> +	[RTM_GETRULE  - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
>  };
>  

Shouldnt this just work (without this change) if you have
CONFIG_IP_MULTIPLE_TABLES?

If you want to be funky and have some default dumper always,
why not make the change to set dumpit to rtnetlink_dump_all in the code
when dumpit is found to be NULL as a last resort?

cheers,
jamal
