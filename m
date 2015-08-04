From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [patch] mpls: small cleanup in inet/inet6_fib_lookup_dev()
Date: Tue, 04 Aug 2015 06:40:21 -0700
Message-ID: <55C0C0C5.1040901@cumulusnetworks.com>
References: <20150804074422.GB10867@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Robert Shearman <rshearma@brocade.com>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150804074422.GB10867@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/4/15, 12:44 AM, Dan Carpenter wrote:
> We recently changed this code from returning NULL to returning ERR_PTR.
> There are some left over NULL assignments which we can remove.  We can
> preserve the error code from ip_route_output() instead of always
> returning -ENODEV.  Also these functions use a mix of gotos and direct
> returns.  There is no cleanup necessary so I changed the gotos to
> direct returns.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
