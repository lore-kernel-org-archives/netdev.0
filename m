From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 13:32:58 -0700 (PDT)
Message-ID: <20050510.133258.08322422.davem@davemloft.net>
References: <1115743966.8570.26.camel@rh4>
	<20050510.121214.39158393.davem@davemloft.net>
	<20050510.132642.85686818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mperaya@alcazaba.unex.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <20050510.132642.85686818.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 13:26:42 -0700 (PDT)

> +			case 1024:
> +			default:
> +				tp->dma_rwctrl |=
> +					(DMA_RWCTRL_READ_BNDRY_512 |
> +					 DMA_RWCTRL_WRITE_BNDRY_512);
> +				break;

This should use the _1024 bit values, of course.
I've fixed that in my local copy.
