From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch net-next] sctp: fix some debug output
Date: Tue, 24 Jan 2017 13:50:07 +0300
Message-ID: <20170124105007.GF4201@mwanda>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42095 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdAXKvV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 05:51:21 -0500
Content-Disposition: inline
In-Reply-To: <20170124091411.GE3781@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 07:14:11AM -0200, Marcelo Ricardo Leitner wrote:
> On Tue, Jan 24, 2017 at 12:05:40PM +0300, Dan Carpenter wrote:
> > We added SCTP_EVENT_TIMEOUT_RECONF but we didn't update this array so
> > it causes an off-by-one read overflow.
> > 
> > Fixes: 7b9438de0cd4 ("sctp: add stream reconf timer")
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Weird, seems your patch is missing the --- marker here.

Are there tools that require the --- marker?  I normally leave it out
when it's not required.

regards,
dan carpenter
