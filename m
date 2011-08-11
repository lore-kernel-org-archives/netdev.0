From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] net/netlabel/netlabel_kapi.c: add missing cleanup code
Date: Thu, 11 Aug 2011 12:44:07 +0300
Message-ID: <20110811094407.GG3777@shale.localdomain>
References: <1313055633-25327-1-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul@paul-moore.com>, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1313055633-25327-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 11, 2011 at 11:40:33AM +0200, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> Use the same cleanup code for the failure of kzalloc as for the failure of
> kstrdup just below.
> 

That doesn't work.  The kfree(entry->domain) would cause an oops.

regards,
dan carpenter
