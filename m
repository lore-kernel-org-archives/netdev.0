From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] [IrDA] Fix IrDA build failure
Date: Wed, 18 Jul 2007 02:17:19 -0700 (PDT)
Message-ID: <20070718.021719.10298885.davem@davemloft.net>
References: <20070716111715.GB22757@mail.solidboot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, eric.y.miao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: samuel.ortiz-EmnPodGKVbzby3iVrkZq2A@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20070716111715.GB22757-OPs8hQ7j6VREYlHNa9+yaNBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel.ortiz-EmnPodGKVbzby3iVrkZq2A@public.gmane.org>
Date: Mon, 16 Jul 2007 14:17:15 +0300

> When having built-in IrDA, we hit the following error:
> 
> `irda_sysctl_unregister' referenced in section `.init.text' of
> net/built-in.o: defined in discarded section `.exit.text' of
> net/built-in.o
> `irda_proc_unregister' referenced in section `.init.text' of
> net/built-in.o: defined in discarded section `.exit.text' of
> net/built-in.o
> `irsock_cleanup' referenced in section `.init.text' of net/built-in.o:
> defined in discarded section `.exit.text' of net/built-in.o
> `irttp_cleanup' referenced in section `.init.text' of net/built-in.o:
> defined in discarded section `.exit.text' of net/built-in.o
> `iriap_cleanup' referenced in section `.init.text' of net/built-in.o:
> defined in discarded section `.exit.text' of net/built-in.o
> `irda_device_cleanup' referenced in section `.init.text' of
> net/built-in.o: defined in discarded section `.exit.text' of
> net/built-in.o
> `irlap_cleanup' referenced in section `.init.text' of net/built-in.o:
> defined in discarded section `.exit.text' of net/built-in.o
> `irlmp_cleanup' referenced in section `.init.text' of net/built-in.o:
> defined in discarded section `.exit.text' of net/built-in.o
> make[1]: *** [.tmp_vmlinux1] Error 1
> make: *** [_all] Error 2
> 
> This is due to the irda_init fix recently added, where we call __exit
> routines from an __init one. It is a build failure that I didn't catch
> because it doesn't show up when building IrDA as a module. My apologies
> for that.
> The following patch fixes that failure and is against your net-2.6
> tree. I hope it can make it to the merge window, and stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
> is CCed on this mail.
> 
> Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

I've applied this.

I realize that alternative suggestions have been made on
how to fix this, and when consensus on that is reached someone
can send me a follow-on patch.

Thanks!

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
