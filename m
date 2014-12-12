From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2 v3] ip: Simplify executing ip cmd within network
 ns
Date: Fri, 12 Dec 2014 08:04:36 +0200
Message-ID: <20141212060436.GA876@angus-think.lan>
References: <1418337171-2792-1-git-send-email-vadim4j@gmail.com>
 <20141211172640.1afc3283@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:63623 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbaLLGO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 01:14:29 -0500
Received: by mail-la0-f48.google.com with SMTP id gf13so5442124lab.7
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 22:14:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141211172640.1afc3283@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2014 at 05:26:40PM -0800, Stephen Hemminger wrote:
> On Fri, 12 Dec 2014 00:32:51 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > +
> > +#define NETNS_RUN_DIR "/var/run/netns"
> > +#define NETNS_ETC_DIR "/etc/netns"
> > +
> > +#ifndef CLONE_NEWNET
> > +#define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
> > +#endif
> > +
> > +#ifndef MNT_DETACH
> > +#define MNT_DETACH	0x00000002	/* Just detach from the tree */
> > +#endif /* MNT_DETACH */
> > +
> > +/* sys/mount.h may be out too old to have these */
> > +#ifndef MS_REC
> > +#define MS_REC		16384
> > +#endif
> > +
> > +#ifndef MS_SLAVE
> > +#define MS_SLAVE	(1 << 19)
> > +#endif
> > +
> > +#ifndef MS_SHARED
> > +#define MS_SHARED	(1 << 20)
> > +#endif
> > +
> > +extern int netns_switch(char *netns);
> > +
> 
> Maybe it would be cleaner to introduce a new file netns.h
> with this and the setnetns syscall wrapper
> 
And MS_*/MNT_* defines to new mount.h ?

Thanks,
