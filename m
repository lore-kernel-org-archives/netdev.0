From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [ofa-general] [PATCH] IB/IPoIB: Fix change mtu when switching
	to UD mode
Date: Tue, 1 Jul 2008 16:45:56 +0300
Message-ID: <20080701134556.GD14384@mtls03>
References: <20080630160651.GA6024@mtls03> <4869CE9C.2050408@voltaire.com>
	<20080701071559.GE6024@mtls03> <486A1CB1.1020904@voltaire.com>
	<20080701134229.GC14384@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	general-list <general@lists.openfabrics.org>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20080701134229.GC14384@mtls03>
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

On Tue, Jul 01, 2008 at 04:42:29PM +0300, Eli Cohen wrote:
> 
> I see, though I would expect to see a comment stating this requirement
> both at the documentation of call_netdevice_notifiers() and that of
> dev_set_mtu() and any other exported functions that requires this kind
> of locking.
> Moreover, in this specific case, it appears that it is not required to
> take the rtlnl lock -- if it would be a must, I would have experienced
> a dump_stack() due to
> 
> ASSERT_RTNL();
> 
> in bond_alb_handle_active_change().

Or some other function registered for notifications.

> 
> 
> The fact that I did not hit such an assert does not mean I may avoid
> taking the rtnl lock but it appears to me that the issue is not well
> undrestood.
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
> 
> To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general
