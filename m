From: kuznet@ms2.inr.ac.ru
Subject: Re: TCP stops sending ACKs after 32 mesg...
Date: Fri, 30 Aug 2002 17:40:08 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200208301340.RAA29215@sex.inr.ac.ru>
References: <20020830112448.GS16533@mea-ext.zmailer.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: matti.aarnio@zmailer.ORG (Matti Aarnio)
In-Reply-To: <20020830112448.GS16533@mea-ext.zmailer.org> from "Matti Aarnio" at Aug 30, 2 05:15:02 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>   I recall having seen this kind of problems in 2.1/2.2 series,
>   possibly a bug-fix was added in late 2.2 to restore earlier
>   behaviour in 2.0...

No, it was repaired only in 2.4. Actually, I think 2.0 behaved approximately
in the same way, the source of the bug is deep in linux approach
to memory accounting and 2.0 was not different.


> > 2) If these processes are run on different Linux m/c's with kernel 
> >    2.2.xx, the problem doesn't appear.
> 
>   Quite so.

No, it appears. Only number "32" is different, on ethernet it changes
to ~90 (for size > rx_copy_break) or 1000.

Alexey
