From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] qdisc oops fix
Date: Wed, 16 Apr 2003 14:18:10 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030416140440.O5912@shell.cyberus.ca>
References: <20030415084706.O1131@shell.cyberus.ca>
 <20030416160606.GA32575@louise.pinerecords.com> <3E9D8A68.5050207@colorfullife.com>
 <200304162003.06600.m.c.p@wolk-project.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Manfred Spraul <manfred@colorfullife.com>,
   Tomas Szepe <szepe@pinerecords.com>, Catalin BOIE <util@deuroconsult.ro>,
   "" <linux-kernel@vger.kernel.org>, "" <netdev@oss.sgi.com>,
   "" <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Marc-Christian Petersen <m.c.p@wolk-project.de>
In-Reply-To: <200304162003.06600.m.c.p@wolk-project.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 16 Apr 2003, Marc-Christian Petersen wrote:

> On Wednesday 16 April 2003 18:52, Manfred Spraul wrote:
>
> Hi Manfred,
>
> > >The original backtrace as provided by Martin Volf does not contain
> > >any weird addresses such as 0xd081ecc7 above:
> > >http://marc.theaimsgroup.com/?l=linux-kernel&m=105013596721774&w=2
> > Thanks.
> > The bug was caused by sch_tree_lock() in htb_change_class().
> > 2.4.21-pre7 contains a fix.
> am I just blind or isn't there a fix in -pre7|current-BK?
>

No you are not ;-> Yes, the fix for that specific problem is in
2.4.21-pre7. I think Tomas might have missed that we moved on to the
next problem.

cheers,
jamal
