From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [26/*] [NET] Kill dst_pmtu/dst_path_metric
Date: Fri, 18 Mar 2005 10:46:00 -0800
Message-ID: <20050318104600.3a3783c5.davem@davemloft.net>
References: <20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050318090310.GA28443@gondor.apana.org.au>
	<20050318091129.GA28658@gondor.apana.org.au>
	<20050318091918.GA28944@gondor.apana.org.au>
	<20050318100757.GA29433@gondor.apana.org.au>
	<20050318101126.GA29583@gondor.apana.org.au>
	<20050318110611.GA5843@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050318110611.GA5843@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 22:06:11 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This would have been the patch that removed dst->path.  But
> ip_append_data got in the way :)
> 
> However, using dst->path is only needed rarely and should always
> require a bit of deliberation.  So let's get rid of dst_pmtu
> and dst_path_metric and use dst_mtu and dst_metric directly.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.

> BTW, shouldn't dst_allfrag be called dst_path_allfrag?

If you think that makes it's functionality clearer, sure.
