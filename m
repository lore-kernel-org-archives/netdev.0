From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] MAINTAINERS: update the NetLabel and Labeled Networking
 information
Date: Fri, 11 Aug 2017 09:25:01 +1000 (AEST)
Message-ID: <alpine.LRH.2.20.1708110924520.25059@namei.org>
References: <150239239837.19177.4190318681371376062.stgit@sifl> <CAHC9VhSk1veoZJvHjVnSy6ztyDdoHBQOVWMyXb8X4Db+-xXENw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([65.99.196.166]:41067 "EHLO namei.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752608AbdHJXZH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 19:25:07 -0400
In-Reply-To: <CAHC9VhSk1veoZJvHjVnSy6ztyDdoHBQOVWMyXb8X4Db+-xXENw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Aug 2017, Paul Moore wrote:

> On Thu, Aug 10, 2017 at 3:13 PM, Paul Moore <pmoore@redhat.com> wrote:
> > From: Paul Moore <paul@paul-moore.com>
> >
> > Signed-off-by: Paul Moore <paul@paul-moore.com>
> > ---
> >  MAINTAINERS |   24 ++++++++++++++----------
> >  1 file changed, 14 insertions(+), 10 deletions(-)
> 
> I'm planning on sending this up via the SELinux tree with some other
> MAINTAINERS updates, consider this more of a FYI posting.

Oops, already applied to -next.

> 
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index 65990909fe73..be25ebaaeec3 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -9112,15 +9112,6 @@ F:       net/*/netfilter/
> >  F:     net/netfilter/
> >  F:     net/bridge/br_netfilter*.c
> >
> > -NETLABEL
> > -M:     Paul Moore <paul@paul-moore.com>
> > -W:     http://netlabel.sf.net
> > -L:     netdev@vger.kernel.org
> > -S:     Maintained
> > -F:     Documentation/netlabel/
> > -F:     include/net/netlabel.h
> > -F:     net/netlabel/
> > -
> >  NETROM NETWORK LAYER
> >  M:     Ralf Baechle <ralf@linux-mips.org>
> >  L:     linux-hams@vger.kernel.org
> > @@ -9248,10 +9239,23 @@ F:      net/ipv6/
> >  F:     include/net/ip*
> >  F:     arch/x86/net/*
> >
> > -NETWORKING [LABELED] (NetLabel, CIPSO, Labeled IPsec, SECMARK)
> > +NETWORKING [LABELED] (NetLabel, Labeled IPsec, SECMARK)
> >  M:     Paul Moore <paul@paul-moore.com>
> > +W:     https://github.com/netlabel
> >  L:     netdev@vger.kernel.org
> > +L:     linux-security-module@vger.kernel.org
> >  S:     Maintained
> > +F:     Documentation/netlabel/
> > +F:     include/net/calipso.h
> > +F:     include/net/cipso_ipv4.h
> > +F:     include/net/netlabel.h
> > +F:     include/uapi/linux/netfilter/xt_SECMARK.h
> > +F:     include/uapi/linux/netfilter/xt_CONNSECMARK.h
> > +F:     net/netlabel/
> > +F:     net/ipv4/cipso_ipv4.c
> > +F:     net/ipv6/calipso.c
> > +F:     net/netfilter/xt_CONNSECMARK.c
> > +F:     net/netfilter/xt_SECMARK.c
> >
> >  NETWORKING [TLS]
> >  M:     Ilya Lesokhin <ilyal@mellanox.com>
> 
> 

-- 
James Morris
<jmorris@namei.org>
