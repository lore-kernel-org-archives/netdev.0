From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH -net] tls: return -EFAULT if copy_to_user() fails
Date: Fri, 23 Jun 2017 13:34:50 +0300
Message-ID: <20170623103450.x2uodbdsz37lwr2c@mwanda>
References: <20170623101544.c5bvwe5cd6e46bd5@mwanda>
 <1498213904.24295.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Watson <davejwatson@fb.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25643 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754510AbdFWKfL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 06:35:11 -0400
Content-Disposition: inline
In-Reply-To: <1498213904.24295.10.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 23, 2017 at 03:31:44AM -0700, Joe Perches wrote:
> On Fri, 2017-06-23 at 13:15 +0300, Dan Carpenter wrote:
> > The copy_to_user() function returns the number of bytes remaining but we
> > want to return -EFAULT here.
> 
> because?

Because it's a failure path?

regards,
dan carpenter
