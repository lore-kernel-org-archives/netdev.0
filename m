From: Andrew Morton <akpm@osdl.org>
Subject: Re: non-fatal oops with EIP at skb_release_data, available for
 debugging
Date: Sun, 29 May 2005 18:21:52 -0700
Message-ID: <20050529182152.60be1979.akpm@osdl.org>
References: <5a4c581d05030412482a596ee5@mail.gmail.com>
	<5a4c581d05040615306f12ebde@mail.gmail.com>
	<20050525220003.5f6ab060.akpm@osdl.org>
	<5a4c581d0505281811a6b067d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alessandro Suardi <alessandro.suardi@gmail.com>
In-Reply-To: <5a4c581d0505281811a6b067d@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alessandro Suardi <alessandro.suardi@gmail.com> wrote:
>
> On 5/26/05, Andrew Morton <akpm@osdl.org> wrote:
>  > Alessandro Suardi <alessandro.suardi@gmail.com> wrote:
>  > >
>  > > Quoting my post of over a month ago, hit another
>  > >  non-fatal oops this time with 2.6.12-rc1-bk2...
>  > 
>  > Has this bug been sighted in more recent kernels?
> 
>  2.6.12-rc2 is the last kernel I've been running on that box
>   and the oops never happened once. I'm waiting for -final
>   or -rc6 and then load it on that K7-800, but so far 2.6.12-rc2
>   has been rock solid. I think it was reaching the 30 days
>   uptime but my building had a power outage last week...

There should be a -rc6.  Please be sure to test that - we don't want to let
2.6.12 out with a bug like this in it, thanks.
