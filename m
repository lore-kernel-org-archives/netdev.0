From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ax25: cleanup a range test
Date: Fri, 18 Oct 2013 13:56:33 -0400 (EDT)
Message-ID: <20131018.135633.1312926688041182414.davem@davemloft.net>
References: <20131018090656.GA23528@longonot.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jreuter@yaina.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20131018090656.GA23528@longonot.mountain>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 18 Oct 2013 12:06:56 +0300

> The current test works fine in practice.  The "amount" variable is
> actually used as a boolean so negative values or any non-zero values
> count as "true".  However since we don't allow numbers greater than one,
> let's not allow negative numbers either.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks Dan.
