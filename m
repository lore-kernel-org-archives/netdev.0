From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2 0/2] lib names: Refactoring and cleanups
Date: Wed, 10 Dec 2014 17:10:29 +0200
Message-ID: <20141210151029.GA18451@angus-think.wlc.globallogic.com>
References: <1417831512-19452-1-git-send-email-vadim4j@gmail.com>
 <20141209203856.491322c0@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:63770 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757421AbaLJPU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 10:20:27 -0500
Received: by mail-la0-f51.google.com with SMTP id ms9so2571726lab.38
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 07:20:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141209203856.491322c0@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2014 at 08:38:56PM -0800, Stephen Hemminger wrote:
> On Sat,  6 Dec 2014 04:05:10 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > Some cleanups and refactoring in lib/rt_names.c:
> > 
> >     #1 Replaced using of /etc/iproute2 path by CONFDIR define
> >         when initializing tables of group names.
> > 
> >     #2 Added helper to have one func for parsing id and names from
> >         db files.
> > 
> > Vadim Kochan (2):
> >   lib names: Use CONFDIR for specify 'group' file path
> >   lib names: Add helper func for parse id and name from file
> > 
> >  lib/rt_names.c | 70 +++++++++++++++++++++++++++++++++-------------------------
> >  1 file changed, 40 insertions(+), 30 deletions(-)
> > 
> 
> Both applied

Hi Stephen,

I see a warning (after 'make clean && make') about using 'const' in lib/rt_names.c:

    static const char * rtnl_rtscope_tab[256] = {
            "global",
    };

which came with PATCH with a subject:

    "lib names: Add helper func for parse id and name from file" (f00073e8b)

but in the PATCH version which was sent by me in email I did not see this.

Why it was needed ?

Regards,
Vadim
