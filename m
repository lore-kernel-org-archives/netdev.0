From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: action stats double dip
Date: Sat, 26 Mar 2005 00:59:55 +0100
Message-ID: <20050325235955.GK3086@postel.suug.ch>
References: <1111767913.1091.530.camel@jzny.localdomain> <1111768884.1092.533.camel@jzny.localdomain> <20050325200650.GC3086@postel.suug.ch> <1111782325.1089.641.camel@jzny.localdomain> <20050325204110.GF3086@postel.suug.ch> <1111786752.1090.678.camel@jzny.localdomain> <20050325215841.GH3086@postel.suug.ch> <1111791991.1091.732.camel@jzny.localdomain> <20050325232431.GJ3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20050325232431.GJ3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20050325232431.GJ3086@postel.suug.ch> 2005-03-26 00:24
> I'm quite sure that you see them perfectly fine but the same stats
> are put once into TCA_OPTIONS (tcf_exts_dump) and again outside of
> it (tcf_exts_dump_stats) which either is simply a duplication or may
> lead to overwriting of a TLV in userspace. But let me check this
> tomorrow, my tree doesn't include your patches yet etc.

Heh, your patch obviously fixes this. Never mind, patch is fine. ;->
