From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: gigabit trouble
Date: Fri, 30 Jul 2004 23:41:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730234120.A15536@electric-eye.fr.zoreil.com>
References: <b71082d8040729094537e59a11@mail.gmail.com> <20040729210401.A32456@electric-eye.fr.zoreil.com> <b71082d80407291541f9d6f93@mail.gmail.com> <b71082d804073008157cf1d6c0@mail.gmail.com> <20040730205412.A15669@electric-eye.fr.zoreil.com> <b71082d804073014037bc5dd5a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart Alewijnse <scarfboy@gmail.com>
Content-Disposition: inline
In-Reply-To: <b71082d804073014037bc5dd5a@mail.gmail.com>; from scarfboy@gmail.com on Fri, Jul 30, 2004 at 11:03:29PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart Alewijnse <scarfboy@gmail.com> :
> You are aware that this is a celeron at 400 mhz, and not whatever 400
> is or possibly isn't in that annoying new naming scheme? (Just
> checking...)

Yes. It is good enough to handle some network traffic.

[...]
> Anyhow, on transmit from the celeron box, under extreme benchy
> circumstrances, I've seen it around 16Kints/s on transmit and 13k on
> receive. But under everyday nfs/samba, 6400 is about the best it does
> either way.

The figures does not seem bad.

I am curious: which chipset does the motherboard include ?
An 'lspci -vx' sums it quite well.

[...]
> This may be due to fiddling with said wmem, etc values, I set some of them

It should not.

> considerably larger. I did get a few percent apparent speed increase,
> incidentally, though that may have been wishful thinking.
> 
> I guess I should try >= 2.6.8-rc2-mm1 next?

Please. Do not compile in preempt/ipv6/smp. SMP is supposed to be safe
but you do not need it and it will not make your r8169 faster if you have
only one CPU. I'd welcome a 'vmstat 1' output as it gives the bi/bo.

--
Ueimor
