From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Route cache performance under stress
Date: 22 May 2003 13:15:39 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1053602138.9475.34.camel@tux.rsn.bth.se>
References: <20030520.173607.88482742.davem@redhat.com>
	 <20030522084003.GA22613@netnation.com>
	 <20030522.015815.91322249.davem@redhat.com>
	 <20030522.034058.71558626.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030522.034058.71558626.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, 2003-05-22 at 12:40, David S. Miller wrote:

> +static unsigned long size_to_order(unsigned long size)
> +{
> +	unsigned long order;
> +
> +	for (order = 0; order < MAX_ORDER; order++) {
> +		if ((PAGE_SIZE << order) >= size)
> +			break;
> +	}
> +	return order;
> +}

Any reason you're not using get_order() ?

-- 
/Martin
