From: John Bradford <john@grabjohn.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Sat, 28 Jun 2003 09:10:32 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200306280810.h5S8AWqi000513@81-2-122-30.bradfords.org.uk>
Cc: davem@redhat.com, greearb@candelatech.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: john@grabjohn.com, lm@bitmover.com, mbligh@aracnet.com
List-Id: netdev.vger.kernel.org

> > This might help.  Or not.
> >
> > Brain dump on the bug tracking problem from the Kernel Summit discussions
>
> I implemented the vast majority of this months ago, in my bug database:
>
> http://www.grabjohn.com/kernelbugdatabase/
>

[snip]

> > Problem details
> >     Bug report quality
> >     	There was lots of discussion on this.  The main agreement was that we
> > 	wanted the bug reporting system to dig out as much info as possible
> > 	and prefill that.  There was a lot of discussion about possible tools
> > 	that would dig out the /proc/pci info; there was discussion about
> > 	Andre's tools which can tell you if you can write your disk; someone
> > 	else had something similar.
>
> This is controversial, due to the potential for unwanted information
> disclosure.  I purposely didn't implement it.  If a large proportion
> of users want it implemented, just let me know.

Having said that, I've had a .config uploading and analysing facility
since version 1.0.  Infact, the reason I forgot to mention it in my
first E-Mail, is that it is the core around which the whole Kernel Bug
Database operates.  The user uploads their .config, and the database
finds bugs that might be the one you're experiencing.  If so, you add
a separate bug report, an admin collects both bug reports in to one
confirmed bug, and picks out which config options he wants to flag as
causing the confirmed bug.

John.
