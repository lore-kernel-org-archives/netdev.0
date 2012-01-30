From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Mon, 30 Jan 2012 20:16:02 +0200
Message-ID: <CAJZOPZLhgDysSASyMLNpOrmGzEyfyHAQjGLVei6ZNSFfb7TM1w@mail.gmail.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	<alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	<CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
	<36F7E4A28C18BE4DB7C86058E7B607240BE9687A@MTRDAG01.mtl.com>
	<CAL1RGDXjjQ-PhCv-9WJX45NuovC9XiS=_7507OsyvLW_gBaJ5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDXjjQ-PhCv-9WJX45NuovC9XiS=_7507OsyvLW_gBaJ5g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2012 at 8:11 PM, Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> But is this general fix so difficult that we can't just do the right thing?

no one said its so difficult, its just not trivial, b/c of the many
use cases over which the GRO logic plays... lets see if the network
folks come with some idea/directive for us.


> Realistically if we add this hack to ipoib then we'll have that ugly
> memset in our fast path forever.

forever, why? once a clever fix is found, we can revert that memset, etc.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
