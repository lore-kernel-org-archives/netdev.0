From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general][PATCH] mlx4_core: Synch catastrophic flow with
	module unload
Date: Mon, 13 Jul 2009 13:09:36 -0700 (PDT)
Message-ID: <20090713.130936.41603615.davem@davemloft.net>
References: <4A5B5274.2020801@mellanox.co.il>
	<20090713.111407.196601373.davem@davemloft.net>
	<adak52cv02r.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adak52cv02r.fsf@cisco.com>
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

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 13 Jul 2009 12:45:32 -0700

>  > Applied, thanks.
> 
> Dave, please don't apply mlx4_core patches without giving me a chance to
> review them.  In this case the patch looks buggy to me: I don't see how
> it handles, say, hot remove of one device -- it only handles module
> removal.  And I would hope we could fix this without adding a global
> symbol as namespace polluting as "drv_mutex".
> 
> Yevgeny didn't even send this patch to you; he just cc'ed netdev as a
> courtesy.  However I understand that the physical location of mlx4_core
> in drivers/net makes it easy to do this.  Maybe this is the best
> argument in favor of moving the mlx4_core stuff to drivers/shared?

If it gets sent to netdev, it's for a networking driver, and it says
"PATCH" rather than "RFC" or "please review" or "don't apply" you
cannot reasonably expect me to not look into applying the thing.

And if you're saying that patches for this device should start not
going through me, and the tactic to accomplish that is to move the
bulk of the driver into some driver/shared area, that's really weird.

Anyways I didn't push the patch out to kernel.org yet so it's easy for
me to remove it.
