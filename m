From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: simplify if clause in dev_close
Date: Mon, 23 Mar 2015 17:02:30 -0400 (EDT)
Message-ID: <20150323.170230.104062959694514151.davem@davemloft.net>
References: <20150323155612.GD24038@mwanda>
	<e902446603472e4ec42118b60f90444b1755501e.1427137720.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	kernel-janitors@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <e902446603472e4ec42118b60f90444b1755501e.1427137720.git.marcelo.leitner@gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Mon, 23 Mar 2015 16:23:12 -0300

> Dan Carpenter's static checker warned that in vxlan_stop we are checking
> if 'vs' can be NULL while later we simply derreference it.
> 
> As after commit 56ef9c909b40 ("vxlan: Move socket initialization to
> within rtnl scope") 'vs' just cannot be NULL in vxlan_stop() anymore, as
> the interface won't go up if the socket initialization fails. So we are
> good to just remove the check and make it consistent.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks.
