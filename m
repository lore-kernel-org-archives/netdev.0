From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: 17 May 2005 23:13:01 +0200
Message-ID: <20050517211300.GB79960@muc.de>
References: <m1k6lx7gkf.fsf@muc.de> <20050517.132202.59028935.davem@davemloft.net> <20050517202730.GA79960@muc.de> <20050517.140245.71090021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, akepner@sgi.com, jheffner@psc.edu,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Tue, 17 May 2005 23:13:00 +0200
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050517.140245.71090021.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2005 at 02:02:45PM -0700, David S. Miller wrote:
> From: Andi Kleen <ak@muc.de>
> Date: 17 May 2005 22:27:30 +0200,Tue, 17 May 2005 22:27:30 +0200
> 
> > But it's not clear such a hack would be worth it anyways. 
> > If anything it would be probably better to let mountd set the RTTs, e.g. 
> > implicitely with MSG_CONFIRM (I hope it is using it these days ...) 
> 
> I think we should implement a solution that goes beyond
> the confines of NFS.

Nothing in MSG_CONFIRM is NFS specific.

-Andi
