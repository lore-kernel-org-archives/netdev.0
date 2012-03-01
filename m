From: Andrei Warkentin <awarkentin@vmware.com>
Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
Date: Thu, 1 Mar 2012 13:04:08 -0800 (PST)
Message-ID: <1191723499.1820816.1330635848166.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
References: <1379096961.1660631.1330451032375.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrei Warkentin <andreiw@vmware.com>,
	Andrei Warkentin <andrey.warkentin@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matt Mackall <mpm@selenic.com>, kgdb-bugreport@lists.sourceforge.net
To: Jason Wessel <jason.wessel@windriver.com>
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
In-Reply-To: <1379096961.1660631.1330451032375.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "Andrei Warkentin" <awarkentin@vmware.com>
> To: "Jason Wessel" <jason.wessel@windriver.com>
> Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Andrei Warkentin" <andreiw@vmware.com>,
> kgdb-bugreport@lists.sourceforge.net, "Matt Mackall" <mpm@selenic.com>, "Andrei Warkentin"
> <andrey.warkentin@gmail.com>
> Sent: Tuesday, February 28, 2012 12:43:52 PM
> Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
> 
> > 
> > All that netpoll_poll() did was to call netpoll_poll_dev().  I have
> > not yet looked at the differences between kgdboe and the netkdb
> > code
> > you proposed but I would have suspected it also falls victim to the
> > ethernet preemption problem which prevented kgdboe from ever being
> > considered for a mainline merge.  Certainly there are ways to fix
> > this
> > problem but most involved changes to scheduling, core net code, or
> > substantial driver specific changes.
> > 
> 
> I see, I read up on the issues w.r.t. preemption. Could this be
> worked
> around by modifiying affected drivers to bypass locking if they are
> used in KDB context? Make some accessor netdev-specific lock/unlocks
> that won't do anything if running in KDB context.
> 
>

By the way, is there a good way to repro the preemption case? Hopefully this doesn't
involve some crazy hardware...

A

------------------------------------------------------------------------------
Virtualization & Cloud Management Using Capacity Planning
Cloud computing makes use of virtualization - but cloud computing 
also focuses on allowing computing to be delivered as a service.
http://www.accelacomm.com/jaw/sfnl/114/51521223/
