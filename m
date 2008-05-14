From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 23:38:44 +0400
Message-ID: <20080514193843.GB10165@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <482B378C.5070807@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sage Weil <sage@newdream.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <482B378C.5070807@garzik.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2008 at 03:03:40PM -0400, Jeff Garzik (jeff@garzik.org) wrote:
> >Well, it depends... If we are talking about single node perfromance,
> >then any protocol, which requries to wait for authorization (or any
> >approach, which waits for acknowledge just after data was sent) is slow.
> 
> Quite true, but IMO single-node performance is largely an academic 
> exercise today.  What production system is run without backups or 
> replication?

If cluster is made out of 2-3-4-10 machines, it does want to get maximum
single node performance. But I agree that in some cases we have to
sacrifice of something in order to find something new. And the larger
cluster becomes, for more things we can close eyes on.
 
-- 
	Evgeniy Polyakov
