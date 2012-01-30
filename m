From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Mon, 30 Jan 2012 11:00:19 -0800
Message-ID: <CAL1RGDVcz5N7u2T-4RV4uqbYjq+Q2vKeuW+ha=DN14Rx5QRkQw@mail.gmail.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
 <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
 <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
 <36F7E4A28C18BE4DB7C86058E7B607240BE9687A@MTRDAG01.mtl.com>
 <CAL1RGDXjjQ-PhCv-9WJX45NuovC9XiS=_7507OsyvLW_gBaJ5g@mail.gmail.com> <CAJZOPZLhgDysSASyMLNpOrmGzEyfyHAQjGLVei6ZNSFfb7TM1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJZOPZLhgDysSASyMLNpOrmGzEyfyHAQjGLVei6ZNSFfb7TM1w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2012 at 10:16 AM, Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Realistically if we add this hack to ipoib then we'll have that ugly
>> memset in our fast path forever.
>
> forever, why? once a clever fix is found, we can revert that memset, etc.

Because no one is ever going to work on the right fix if we add a
bandaid to ipoib now.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
