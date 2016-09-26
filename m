From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 5/5] ISDN-CAPI: Delete unnecessary braces
Date: Mon, 26 Sep 2016 11:20:42 +0200
Message-ID: <1474881642.1846.14.camel@tiscali.nl>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
         <06e7637c-f682-bfa2-82b6-47d071bd58c4@users.sourceforge.net>
         <52dd5000-2bda-a1b6-aa97-1868e1193d35@cogentembedded.com>
         <727b14d4-7a3b-9de8-25d9-c3bf212f7c44@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud6.xs4all.net ([194.109.24.31]:40915 "EHLO
        lb3-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S938822AbcIZJUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:20:49 -0400
In-Reply-To: <727b14d4-7a3b-9de8-25d9-c3bf212f7c44@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-09-25 at 14:47 +0200, SF Markus Elfring wrote:
> > > @@ -976,13 +974,12 @@ static void handle_controller(_cmsg *cmsg)
> > >          if (debugmode)
> > >              printk(KERN_DEBUG "capidrv-%d: listenconf Info=0x%4x
> > > (%s) cipmask=0x%x\n",
> > >                     card->contrnr, cmsg->Info,
> > > capi_info2str(cmsg->Info), card->cipmask);
> > > -        if (cmsg->Info) {
> > > +        if (cmsg->Info)
> > >              listen_change_state(card, EV_LISTEN_CONF_ERROR);
> > > -        } else if (card->cipmask == 0) {
> > > +        else if (card->cipmask == 0)
> > >              listen_change_state(card, EV_LISTEN_CONF_EMPTY);
> > > -        } else {
> > > +             else
> > 
> >    Indented too much.
> 
> How do you think about an alignment of this "else"
> with the corresponding if statement three lines above?

Well, I think it looks silly. checkpatch apparently agrees:
    WARNING: Statements should start on a tabstop
    #51: FILE: drivers/isdn/capi/capidrv.c:981:
    +		     else
    
    total: 0 errors, 1 warnings, 91 lines checked
    
    NOTE: For some of the reported defects, checkpatch may be able to
          mechanically convert to the typical style using --fix or --fix-inplace.
    
    Your patch has style problems, please review.
    
    NOTE: If any of the errors are false positives, please report
          them to the maintainer, see CHECKPATCH in MAINTAINERS.

You use checkpatch a lot, don't you? Didn't you use it to, you know,
check your patch?


Paul Bolle
