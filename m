From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: [PATCH] qdisc oops fix
Date: Wed, 16 Apr 2003 23:44:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030416214422.GM32575@louise.pinerecords.com>
References: <20030415084706.O1131@shell.cyberus.ca> <20030416160606.GA32575@louise.pinerecords.com> <3E9D8A68.5050207@colorfullife.com> <200304162003.06600.m.c.p@wolk-project.de> <20030416140440.O5912@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc-Christian Petersen <m.c.p@wolk-project.de>,
   Manfred Spraul <manfred@colorfullife.com>,
   Catalin BOIE <util@deuroconsult.ro>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20030416140440.O5912@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> [hadi@cyberus.ca]
> >
> > > >The original backtrace as provided by Martin Volf does not contain
> > > >any weird addresses such as 0xd081ecc7 above:
> > > >http://marc.theaimsgroup.com/?l=linux-kernel&m=105013596721774&w=2
> > > Thanks.
> > > The bug was caused by sch_tree_lock() in htb_change_class().
> > > 2.4.21-pre7 contains a fix.
> > am I just blind or isn't there a fix in -pre7|current-BK?
> >
> 
> No you are not ;-> Yes, the fix for that specific problem is in
> 2.4.21-pre7. I think Tomas might have missed that we moved on to the
> next problem.

Trouble is, the fix went in for already -pre5 (cset 1.930.3.5), so if you
only look at the pre6->pre7 changelog (like I did), you aren't likely to
find it.  8)

T.
