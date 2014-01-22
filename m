From: David Miller <davem@davemloft.net>
Subject: Re: [patch] rxrpc: out of bound read in debug code
Date: Tue, 21 Jan 2014 17:03:11 -0800 (PST)
Message-ID: <20140121.170311.1774535393379603151.davem@davemloft.net>
References: <20140120102859.GA14233@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140120102859.GA14233@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 20 Jan 2014 13:28:59 +0300

> Smatch complains because we are using an untrusted index into the
> rxrpc_acks[] array.  It's just a read and it's only in the debug code,
> but it's simple enough to add a check and fix it.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
