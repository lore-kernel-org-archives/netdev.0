From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH -net] tls: return -EFAULT if copy_to_user() fails
Date: Fri, 23 Jun 2017 14:29:01 +0300
Message-ID: <20170623112900.nhbtfwa5mtrxtt4d@mwanda>
References: <20170623101544.c5bvwe5cd6e46bd5@mwanda>
 <1498213904.24295.10.camel@perches.com>
 <20170623103612.ycduw43oyi6hmtp3@mwanda>
 <1498215515.24295.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Watson <davejwatson@fb.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1498215515.24295.12.camel@perches.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2017 at 03:58:35AM -0700, Joe Perches wrote:
> getsockopt says:
> 
> For getsockopt(), optlen is a value-result argument, initially containing the size
> of the buffer pointed to by optval, and modified on return to indicate the actual
> size of the value returned

In the original code, it's not returning the "actual size of the value
returned". It's returning a smaller or equal value... The man page is
correct that this is how some getsockopts work, of course.  But here
-EFAULT is expected.

regards,
dan carpenter

