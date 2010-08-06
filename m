From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: convert to rcu_dereference_index_check()
Date: Fri, 6 Aug 2010 14:54:47 -0700
Message-ID: <20100806215447.GM2432@linux.vnet.ibm.com>
References: <20100806212607.GA9410@linux.vnet.ibm.com>
 <20100806.144901.184847372.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:33819 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762091Ab0HFVyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 17:54:49 -0400
Content-Disposition: inline
In-Reply-To: <20100806.144901.184847372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 06, 2010 at 02:49:01PM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Fri, 6 Aug 2010 14:26:07 -0700
> 
> > At long last, the following is the final patch blocking acceptance
> > of Arnd's sparse annotations for RCU.  It was itself blocked behind
> > the definition of rcu_dereference_index_check(), which made it to
> > mainline only just today.
> > 
> > Would you be willing to ack this patch so that I can push it to -tip,
> > along with Arnd's work and a bunch of other stuff?
>  ...
> >     net: convert to rcu_dereference_index_check()
> >     
> >     The task_cls_classid() function applies rcu_dereference() to integers,
> >     which does not work with the shiny new sparse-based checking in
> >     rcu_dereference().  This commit therefore moves to the new RCU API
> >     rcu_dereference_index_check().
> >     
> >     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >     Reviewed-by: Josh Triplett <josh@joshtriplett.org>
> 
> You should of course wait for Herbert's ACK too, but for
> the record:
> 
> Acked-by: David S. Miller <davem@davemloft.net>
> 
> :-)

Thank you, David!!!  ;-)

							Thanx, Paul
