From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 4/5] pm: move pm notifiers into suspend.h
Date: Thu, 23 Jun 2011 22:24:36 +0200
Message-ID: <20110623202436.GB8514@elf.ucw.cz>
References: <1308724522-32461-1-git-send-email-amwang@redhat.com>
 <1308724522-32461-5-git-send-email-amwang@redhat.com>
 <201106222149.28252.rjw@sisk.pl>
 <4E02C93A.7010601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Chris Ball <cjb@laptop.org>, Len Brown <len.brown@intel.com>,
	Ohad Ben-Cohen <ohad@wizery.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Philip Rakity <prakity@marvell.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>,
	linux-mmc@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E02C93A.7010601@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 2011-06-23 13:03:54, Cong Wang wrote:
> ??? 2011???06???23??? 03:49, Rafael J. Wysocki ??????:
> >>+#ifdef CONFIG_PM
> >>>  +#include<linux/suspend.h>
> >>>  +#endif
> >I don't think the #ifdef in necessary.  Any dependencies on CONFIG_PM
> >(or CONFIG_SUSPEND etc.) should be taken care of inside of suspend.h.
> >This file should be fixed if they aren't.
> >
> 
> Ok, please check the updated version below.
> 
> Thanks.
> 

> Author: Amerigo Wang <amwang@redhat.com>
> 
>     pm: move pm notifiers into suspend.h
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

ACK.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
