From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [Bug #12805] QinQ vlan trunking regression
Date: Sat, 14 Mar 2009 23:26:10 +0100
Message-ID: <200903142326.11185.rjw@sisk.pl>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera> <GCLaknAim2M.A.RgD.w4BvJB@chimera> <20090314.150420.149174658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bart-LIbhotJ4rFdeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090314.150420.149174658.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 14 March 2009, David Miller wrote:
> From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
> Date: Sat, 14 Mar 2009 20:05:33 +0100 (CET)
> 
> > This message has been generated automatically as a part of a report
> > of recent regressions.
> > 
> > The following bug entry is on the current list of known regressions
> > from 2.6.28.  Please verify if it still should be listed and let me know
> > (either way).
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12805
> > Subject		: QinQ vlan trunking regression
> > Submitter	: Bart Trojanowski <bart-LIbhotJ4rFdeoWH0uzbU5w@public.gmane.org>
> > Date		: 2009-02-28 18:05 (15 days old)
> > References	: http://marc.info/?l=linux-kernel&m=123584439115868&w=4
> 
> Fixed by:
> 
> commit 9d40bbda599def1e1d155d7f7dca14fe8744bd2b
> Author: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Date:   Wed Mar 4 23:46:25 2009 -0800
> 
>     vlan: Fix vlan-in-vlan crashes.
>     
>     As analyzed by Patrick McHardy, vlan needs to reset it's
>     netdev_ops pointer in it's ->init() function but this
>     leaves the compat method pointers stale.
>     
>     Add a netdev_resync_ops() and call it from the vlan code.
>     
>     Any other driver which changes ->netdev_ops after register_netdevice()
>     will need to call this new function after doing so too.
>     
>     With help from Patrick McHardy.
>     
>     Tested-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
>     Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Thanks, closed.

Rafael
