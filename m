From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH] SIW: Documentation (initial)
Date: Tue, 19 Oct 2010 17:36:05 +0200
Message-ID: <OF1E46C86F.75091985-ONC12577C1.0054327F-C12577C1.0055B3DD@ch.ibm.com>
References: <20101014155703.3d4b5d71.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101014155703.3d4b5d71.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Randy,

...back from vacation.
Many thanks! I'll take it all over.


Bernard.

Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote on 10/15/2010 12:57:03 AM:

<snip>

> > +
> > +User Interface
> > +--------------
> > +All fast path operations such as posting of work requests and
> > +reaping of work completions currently involve a system call into
> > +the siw module. Kernel/user-mapped send and receive as well as
>
> I didn't find the system call(s).  Are they new syscalls or just
> (socket) reads/writes?  (I was probably looking for new syscalls.)
>

I will have to clarify. Currently all operations are using the
infiniband/core infrastructure (e.g. via uverbs write file
operation). There is no private interface between libsiw and
siw kernel module in place.


<snip>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
