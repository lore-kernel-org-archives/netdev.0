From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Problem with "ESP: sha1 digestsize 20 != 0"
Date: Thu, 03 Feb 2005 22:02:33 +0100
Message-ID: <1107464553.6911.0.camel@pegasus>
References: <E1CwnlK-0001rv-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Network Development Mailing List <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CwnlK-0001rv-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

> > when using my RAS account with 2.6.11-rc3, I see a lot of
> > 
> > 	ESP: sha1 digestsize 20 != 0
> > 
> > messages in my logs and the IPsec tunnel is not working. I tracked the
> > problem down to the change below. After reverting this patch, everything
> > works like before.
> 
> Sorry, my fault.
> 
> The name test in xfrm_get_byname is inverted.

now it is working again. Thanks.

Regards

Marcel
