From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH net] mcs7780: Silence uninitialized variable warning
Date: Tue, 1 Aug 2017 13:45:17 +0300
Message-ID: <20170801104516.7n2uwq5wv64qaq4d@mwanda>
References: <20170728144511.tf7nc672hwo35rnn@mwanda>
 <20170729.232855.1831311386560187695.davem@davemloft.net>
 <20170731070925.ztlfbyd7pvoz46wh@mwanda>
 <20170731.103716.2203333144439591434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170731.103716.2203333144439591434.davem@davemloft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2017 at 10:37:16AM -0700, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Mon, 31 Jul 2017 10:41:40 +0300
> 
> > On Sat, Jul 29, 2017 at 11:28:55PM -0700, David Miller wrote:
> >> From: Dan Carpenter <dan.carpenter@oracle.com>
> >> Date: Fri, 28 Jul 2017 17:45:11 +0300
> >> 
> >> > -	__u16 rval;
> >> > +	__u16 rval = -1;
> >> 
> >> Fixing a bogus warning by assigning a signed constant to an
> >> unsigned variable doesn't really make me all that happy.
> >> 
> >> I don't think I'll apply this, sorry.
> > 
> > There's no guarantee that small kmallocs will always succeed in future
> > kernels so it's not *totally* bogus.
> 
> Perhaps the burdon of initializing the value belongs in
> mcs_get_reg(), and you can set it properly to 0xffff
> instead of -1.
> 
> Ok?

Sure.  I will resend.

thanks,
dan carpenter
