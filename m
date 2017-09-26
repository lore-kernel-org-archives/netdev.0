From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH] lib: fix multiple strlcpy definition
Date: Tue, 26 Sep 2017 19:27:45 +0300
Message-ID: <20170926162745.kxl3m42hfprhqhd3@tarshish>
References: <7f5fee59e46bfd3b4acf8ed9a8fbd8c7b4f1cd70.1506424129.git.baruch@tkos.co.il>
 <20170926155524.GA26610@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:50072 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966562AbdIZQ1u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 12:27:50 -0400
Content-Disposition: inline
In-Reply-To: <20170926155524.GA26610@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phil,

On Tue, Sep 26, 2017 at 05:55:24PM +0200, Phil Sutter wrote:
> On Tue, Sep 26, 2017 at 02:08:49PM +0300, Baruch Siach wrote:
> [...]
> > diff --git a/configure b/configure
> > index 7be8fb113cc9..787b2e061af9 100755
> > --- a/configure
> > +++ b/configure
> > @@ -326,6 +326,27 @@ EOF
> >      rm -f $TMPDIR/dbtest.c $TMPDIR/dbtest
> >  }
> >  
> > +check_strlcpy()
> > +{
> > +    cat >$TMPDIR/strtest.c <<EOF
> > +#include <string.h>
> > +int main(int argc, char **argv) {
> > +	char dst[10];
> > +	strlcpy("test", dst, sizeof(dst));
> 
> You swapped source and destination here. It's not important for the
> given use-case, but the resulting binary should segfault.

Will fix that in v2.

> Apart from that, LGTM!

Thanks. I'll take this as an ack.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -
