From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] select appropriate skb size in tcp_sendmsg when TSO is
 used
Date: Tue, 26 Oct 2004 19:54:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417EE3BB.6040902@pobox.com>
References: <OF96546AB5.ACE12043-ONC1256F33.0027BC6B-C1256F33.002D4A6E@de.ibm.com> <E1CKE5P-0005SP-00@gondolin.me.apana.org.au> <20041020163510.6d13e9c7.davem@davemloft.net> <20041026111912.GA18095@gondor.apana.org.au> <20041026235126.GA4733@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, thomas.spatzier@de.ibm.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041026235126.GA4733@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> +static int __ethtool_set_sg(struct net_device *dev, u32 data)
> +{
> +	int err;
> +
> +	if (!data && dev->ethtool_ops->set_tso) {
> +		err = dev->ethtool_ops->set_tso(dev, 0);
> +		if (err)
> +			return err;
> +	}
> +
> +	return dev->ethtool_ops->set_sg(dev, data);
> +}

you want to disable tx-csum also
