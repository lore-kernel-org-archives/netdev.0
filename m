From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 22:29:10 +0200
Message-ID: <20070318202910.GE11078@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318195355.GB11078@mellanox.co.il>
	<20070318201826.GB27004@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070318201826.GB27004@ms2.inr.ac.ru>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

> > > It should be cleared and we should be sure it will not be destroyed
> > > before quiescent state.
> > 
> > I'm confused. didn't you say dst_ifdown is called after quiescent state?
> 
> Quiescent state should happen after dst->neighbour is invalidated.
> And this implies that all the users of dst->neighbour check validity
> after dereference and do not use it after quiescent state.
> 
> 
> > This does not sound like something that's likely to be accepted in 2.6.21, right?
> > 
> > Any simpler ideas?
> 
> Well, if inifiniband destructor really needs to take that lock... no.
> Right now I do not see.

OK then.
If you post some patches I'll test them.

-- 
MST
