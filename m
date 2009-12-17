From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] Security: Add prctl(PR_{GET,SET}_NETWORK) interface.
Date: Thu, 17 Dec 2009 09:25:20 -0800
Message-ID: <20091217092520.1f65d2dd.randy.dunlap@oracle.com>
References: <1260977452-2334-1-git-send-email-michael@laptop.org>
	<1260977565-2379-1-git-send-email-michael@laptop.org>
	<20091217092326.484bb318.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	"Andi Kleen" <andi@firstfloor.org>, "David Lang" <david@lang.hm>,
	"Oliver Hartkopp" <socketcan@hartkopp.net>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Valdis Kletnieks" <Valdis.Kletnieks@vt.edu>,
	"Bryan Donlan" <bdonlan@gmail.com>,
	"Evgeniy Polyakov" <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	"James Morris" <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Bernie Innocenti" <bernie@codewiz.org>,
	"Mark Seaborn" <mrs@mythic-beasts.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091217092326.484bb318.randy.dunlap@oracle.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Dec 2009 09:23:26 -0800 Randy Dunlap wrote:

> On Wed, 16 Dec 2009 10:32:43 -0500 Michael Stone wrote:
> 
> 
> > ---
> >  include/linux/prctl.h         |    7 +++++++
> >  include/linux/prctl_network.h |    7 +++++++
> >  include/linux/sched.h         |    2 ++
> >  kernel/Makefile               |    2 +-
> >  kernel/prctl_network.c        |   37 +++++++++++++++++++++++++++++++++++++
> >  kernel/sys.c                  |    7 +++++++
> >  6 files changed, 61 insertions(+), 1 deletions(-)
> >  create mode 100644 include/linux/prctl_network.h
> >  create mode 100644 kernel/prctl_network.c
> > 
> 
> > diff --git a/kernel/prctl_network.c b/kernel/prctl_network.c
> > new file mode 100644
> > index 0000000..d173716
> > --- /dev/null
> > +++ b/kernel/prctl_network.c
> > @@ -0,0 +1,37 @@
> > +/*
> > + * linux/kernel/prctl_network.c
> > + *
> > + * Copyright 2009  Michael Stone <michael@laptop.org>
> > + *
> > + * Turn off a process's ability to access new networks.
> > + * See Documentation/prctl_network.txt for details.
> > + */
> 
> Where is Documentation/prctl_network.txt ?
> and it should probably be Documentation/prctl/network.txt .

gag, I see it.  Sorry about that.
I think that the file name still needs to be changed.

---
~Randy
