From: David Miller <davem@davemloft.net>
Subject: Re: [patch] mpls: small cleanup in inet/inet6_fib_lookup_dev()
Date: Thu, 06 Aug 2015 21:57:05 -0700 (PDT)
Message-ID: <20150806.215705.2259534799573368398.davem@davemloft.net>
References: <20150804074422.GB10867@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com,
	roopa@cumulusnetworks.com, tom@herbertland.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150804074422.GB10867@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 4 Aug 2015 10:44:22 +0300

> We recently changed this code from returning NULL to returning ERR_PTR.
> There are some left over NULL assignments which we can remove.  We can
> preserve the error code from ip_route_output() instead of always
> returning -ENODEV.  Also these functions use a mix of gotos and direct
> returns.  There is no cleanup necessary so I changed the gotos to
> direct returns.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
