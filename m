From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 1/2] ip: include libc headers first
Date: Wed, 31 May 2017 23:59:35 +0300
Message-ID: <20170531205935.ub3zhgkg4juep7b5@tarshish>
References: <8afdd8babb9e82bcfde78e851b24b698436a6f9f.1495459674.git.baruch@tkos.co.il>
 <20170530173151.771ea254@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:40617 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751116AbdEaU7k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 16:59:40 -0400
Content-Disposition: inline
In-Reply-To: <20170530173151.771ea254@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Tue, May 30, 2017 at 05:31:51PM -0700, Stephen Hemminger wrote:
> On Mon, 22 May 2017 16:27:53 +0300
> Baruch Siach <baruch@tkos.co.il> wrote:
> 
> > Including libc headers first helps as a workaround to redefinition of struct
> > ethhdr with a suitably patched musl libc that suppresses the kernel
> > if_ether.h.
> > 
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > ---
> >  ip/iplink_bridge.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
> > index 818b43c89b5b..cccdec1c203a 100644
> > --- a/ip/iplink_bridge.c
> > +++ b/ip/iplink_bridge.c
> > @@ -13,9 +13,9 @@
> >  #include <stdlib.h>
> >  #include <string.h>
> >  #include <netinet/in.h>
> > +#include <netinet/ether.h>
> >  #include <linux/if_link.h>
> >  #include <linux/if_bridge.h>
> > -#include <netinet/ether.h>
> >  #include <net/if.h>
> >  
> >  #include "rt_names.h"
> 
> Applied.

Thanks.

> Next time please fix the Subject line.  You implied two patches by using 1/2
> but only one was sent.

You have seen and responded[1] to patch 2/2 in this series. Eventually that 
patch turned out to be redundant, so you committed cda81a4ea5e (include: 
remove no longer used iptables_common.h) instead.

> It is easier for me if you include iproute2 in subject since then it goes 
> into a separate folder.
> 
> Subject: [PATCH iproute2] ip: include libc headers first
> 
> or if intended for net-next
> 
> Subject: [PATCH iproute2 net-next] ip: add magic VRF support

I will remember that for next time.

[1] http://marc.info/?l=linux-netdev&m=149547389506859

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -
