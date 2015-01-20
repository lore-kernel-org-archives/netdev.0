From: David Miller <davem@davemloft.net>
Subject: Re: [patch] s2io: use snprintf() as a safety feature
Date: Mon, 19 Jan 2015 19:45:37 -0500 (EST)
Message-ID: <20150119.194537.2076072305947176887.davem@davemloft.net>
References: <20150119193451.GB32634@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150119193451.GB32634@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 19 Jan 2015 22:34:51 +0300

> "sp->desc[i]" has 25 characters.  "dev->name" has 15 characters.  If we
> used all 15 characters then the sprintf() would overflow.
> 
> I changed the "sprintf(sp->name, "%s Neterion %s"" to snprintf(), as
> well, even though it can't overflow just to be consistent.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
