From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] [IrDA] Fix RCU lock pairing on error
	path
Date: Thu, 29 Jun 2006 17:02:44 -0700 (PDT)
Message-ID: <20060629.170244.104032326.davem@davemloft.net>
References: <1151542602.18723.19.camel@josh-work.beaverton.ibm.com>
	<20060629142741.GA1294@us.ibm.com>
	<20060630065534.GA4729@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm-3NddpPZAyC0@public.gmane.org, josht-DhXWPJtHtuFWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulmck-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, dipankar-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
In-Reply-To: <20060630065534.GA4729-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Date: Fri, 30 Jun 2006 09:55:34 +0300

> irlan_client_discovery_indication calls rcu_read_lock and rcu_read_unlock, but
> returns without unlocking in an error case.  Fix that by replacing the return
> with a goto so that the rcu_read_unlock always gets executed.
> 
> Signed-off-by: Josh Triplett <josh-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
> Acked-by: Paul E. McKenney <paulmck-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Samuel Ortiz samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org <>

Applied, thanks.

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
