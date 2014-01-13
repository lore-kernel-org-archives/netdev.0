From: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Subject: Re: [PATCH] xprtrdma: silence frame size warning
Date: Mon, 13 Jan 2014 20:35:50 +0100
Message-ID: <1389641750.19054.9.camel@x220>
References: <1389627955.20467.9.camel@x41>
	 <CDD9CEF2-F91A-4ABA-8DA7-53AF8A749194@primarydata.com>
	 <D3560A1A-59B3-4480-8627-9114A4B9895C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"Miller David S." <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <D3560A1A-59B3-4480-8627-9114A4B9895C-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-13 at 11:17 -0500, Chuck Lever wrote:
> I=E2=80=99m building a queue of NFS/RDMA work on bugzilla.kernel.org.=
  Let=E2=80=99s
> create a defect report there to document this, and it will get
> prioritized with the rest.  Paul, can you do that to start us off?
> Product =E2=80=9CFile system=E2=80=9D, Component =E2=80=9CNFS=E2=80=9D=
=2E

Sure, see https://bugzilla.kernel.org/show_bug.cgi?id=3D68661 . Please
feel free to edit the bug's title, etc, as you see fit.

> I can=E2=80=99t say that a warning on 32-bit x86 is going to be an es=
pecially
> high priority.

I see. 32-bit x86 seems to be dropping in relevance quite fast.

On the other hand, this is one of the last warnings I see when currentl=
y
building x86 (32-bit, that is) and it would be rather nice to see this
warning gone. Since my .config is basically a Fedora 20 .config, that
would help make Fedora's 32-bit x86 build (almost) warning free too.=20

> However, the underlying issue of allocating arrays of data segments o=
n
> the stack is something that needs extended attention, and is already
> in plan.

Thanks,


Paul Bolle

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
