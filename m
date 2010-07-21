From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Tue, 20 Jul 2010 18:27:54 -0700 (PDT)
Message-ID: <20100720.182754.140729379.davem@davemloft.net>
References: <20100720122032.88e0fcd9.sfr@canb.auug.org.au>
	<1279593240.19374.2.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	jdike@addtoit.com, mst@redhat.com
To: joe@perches.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1279593240.19374.2.camel@Joe-Laptop.home>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 19 Jul 2010 19:34:00 -0700

> On Tue, 2010-07-20 at 12:20 +1000, Stephen Rothwell wrote:
>> I fixed it up (see below) and can carry the fix as necessary.
> @@@ -527,15 -527,12 +527,14 @@@ static long vhost_net_set_backend(struc
>   
>         /* start polling new socket */
>         oldsock = vq->private_data;
> -       if (sock == oldsock)
> -               goto done;
> +       if (sock != oldsock){
> 
> Trivial: missing space before open brace in commit
> dd1f4078f0d2de74a308f00a2dffbd550cfba59f

Thanks guys, I'm taking care of this as I merge net-2.6 into
net-next-2.6
