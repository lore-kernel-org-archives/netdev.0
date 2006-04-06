From: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] IrDA: smcinit merged into smsc-ircc driver
Date: Wed, 05 Apr 2006 22:34:57 -0700 (PDT)
Message-ID: <20060405.223457.117830244.davem@davemloft.net>
References: <20060405232125.GA377@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org
In-Reply-To: <20060405232125.GA377@irie>
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date: Thu, 6 Apr 2006 02:21:25 +0300

> This patch integrates the smcinit code into the smsc-ircc driver.
> Some laptops have their smsc-ircc chip not properly configured by the BIOS and needs some preconfiguration. Currently, this can be done from userspace with smcinit, a utility that comes with the irda-utils package. It messes with ioports and PCI settings, from userspace.
> Now with this patch, if we happen to be on one of the known to be faulty laptops, we preconfigure the chip from the driver.
> 
> Patch from Linus Walleij <triad-HEm3bjczhZmzQB+pC5nmwQ@public.gmane.org>
> Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

Applied.

This patch added a lot of trailing whitespace which I had to
fix up by hand, I did it for you this time but next time I
will not.  You can check you patches with this simple command:

git apply --check --whitespace=error-all diff

Thanks.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
