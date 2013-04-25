From: David Miller <davem@davemloft.net>
Subject: Re: [patch] netrom: info leak in ->getname()
Date: Thu, 25 Apr 2013 01:48:58 -0400 (EDT)
Message-ID: <20130425.014858.1706001591492099470.davem@davemloft.net>
References: <20130423062251.GB15893@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20130423062251.GB15893@elgon.mountain>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 23 Apr 2013 09:22:51 +0300

> The sockaddr_ax25 struct has a 3 byte hole between ->sax25_call and
> ->sax25_ndigis.  I've added a memset to avoid leaking uninitialized
> stack data to userspace.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
