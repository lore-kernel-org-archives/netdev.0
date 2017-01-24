From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch net-next] sctp: fix some debug output
Date: Tue, 24 Jan 2017 12:51:04 +0300
Message-ID: <20170124095104.GA4149@mwanda>
References: <20170124090540.GA27652@mwanda>
 <20170124091411.GE3781@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Colin King <colin.king@canonical.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170124091411.GE3781@localhost.localdomain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2017 at 07:14:11AM -0200, Marcelo Ricardo Leitner wrote:
> On Tue, Jan 24, 2017 at 12:05:40PM +0300, Dan Carpenter wrote:
> > We added SCTP_EVENT_TIMEOUT_RECONF but we didn't update this array so
> > it causes an off-by-one read overflow.
> > 
> > Fixes: 7b9438de0cd4 ("sctp: add stream reconf timer")
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Weird, seems your patch is missing the --- marker here.
> Colin (Cc'ed) is supposed to post a v3 of his patch containing this fix.
> 

Colin, if you wanted, you could CC kernel-janitors with static checker
fixes.  There are several of us on that list.

regards,
dan carpenter

