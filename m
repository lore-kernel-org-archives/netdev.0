From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH 8/8] orinoco: New driver - spectrum_cs.
Date: Fri, 09 Sep 2005 18:40:09 -0400
Message-ID: <1126305609.16679.1.camel@dv>
References: <1125619806.29016.11.camel@dv>
	 <20050906112424.GA5309@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
In-Reply-To: <20050906112424.GA5309-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

On Tue, 2005-09-06 at 12:24 +0100, Christoph Hellwig wrote:
> > +#ifdef  __IN_PCMCIA_PACKAGE__
> > +#include <pcmcia/k_compat.h>
> > +#endif /* __IN_PCMCIA_PACKAGE__ */
> 
> this doesn't make sense for a 2.6 driver.

Fixed in my tree, thanks.  Patches will be sent shortly.

> > +#ifdef SPECTRUM_FW_INCLUDED
> > +/* Header with the firmware */
> > +#include "spectrum_fw.h"
> > +#else	/* !SPECTRUM_FW_INCLUDED */
> 
> While I see the point of this for the standalone orinoco driver package
> it doesn't make sense for the version in the kernel tree.

Likewise.

> 
> > +#define CS_CHECK(fn, ret) \
> > +  do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
> 
> I don't think this macro abuse helps anyone..

Sure, but it's abused by many drivers.  Maybe next time.

-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
