From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Subject: Re: [PATCH] ebtables: Port ebt_[u]log.c to nf[netlink]_log
Date: Tue, 11 Oct 2005 19:31:50 +0000
Message-ID: <1129059110.5087.8.camel@localhost.localdomain>
References: <20051007234903.GR4450@rama.customers.eurospot.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
In-Reply-To: <20051007234903.GR4450-5xaKNk1AN7bNqB9Gf7YOJg/oQhhTQFE7QQ4Iyu8u01E@public.gmane.org>
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ebtables-devel>
List-Id: netdev.vger.kernel.org

Op za, 08-10-2005 te 01:49 +0200, schreef Harald Welte:
> Hi Bart!
> 
> The patch below is totally untested (though it compiles), and updates
> ebtables to resemble the behaviour that we now have in ipv4 (and ipv6):
> {ip,ip6,eb}tables just tell the nf_log core that they want to log a
> packet, the mechanism (syslog, nfnetlink_log, ...) is actually decided
> by nf_log.
> 
> By default, everything will behave like before.
> 
> Please review, and test that ebt_log and ebt_ulog are still working as
> expected.  Thanks!
> 
> [NETFILTER] ebtables: Port ebt_[u]log.c to nf[netlink]_log
> 
> Since we now have a netfilter core logging API, we port the bridging log
> and ulog watchers to this new API.
> 
> This basically means that if you use the "ebt_log" watcher, it will by
> default log to the system console, but enables a userspace logging daemon
> binds itself to PF_BRIDGE, and take over all logging.
> 
> ebt_ulog also registers itself as logger with nf_log, but any packets
> explicitly send to ebt_ulog will always use the ulog mechanism and not
> handled via the generic logging handler.
> 
> This change resembles the situation that is now present in ipv4.

I seem to be unable to get Davem's current git tree.
This fails miserably: 
cg-clone http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git

Your patch won't apply to 2.6.13. At first I thought it was a problem
with evolution or the kernel version, but looking at the source code of
your mail, I see "=20" added here and there...

Any ideas?

cheers,
Bart




-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
