From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()
Date: Wed, 11 Nov 2009 10:25:48 -0800
Message-ID: <adaocn8x6j7.fsf@roland-alpha.cisco.com>
References: <4AF8EBA4.2070102@gmail.com>
	<D5E1FB213939498DBFFEB5A3B83C08AD@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Eric Dumazet'" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Linux Netdev List" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Roland Dreier" <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"Hal Rosenstock" <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Sean Hefty" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <D5E1FB213939498DBFFEB5A3B83C08AD-Zpru7NauK7drdx17CPfAsdBPR1lH4CV8@public.gmane.org> (Sean
	Hefty's message of "Wed, 11 Nov 2009 10:18:47 -0800")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


 > >for_each_netdev() should be used with RTNL or dev_base_lock held,
 > >or risk a crash.
 > >
 > >Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
 > 
 > Thanks - I'm working on a patch set in this area.  Roland, I can merge Eric's
 > changes into that patch set if it makes things easier.

Would it be possible for you to take Eric's patch as the first in your
set (keeping his From: of course) and base your fixes on top of that?
That seems the cleanest thing to me.

Thanks,
  Roland
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
