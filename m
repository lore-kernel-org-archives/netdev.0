From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: ip_set: protocol %u message -- useful?
Date: Thu, 13 Feb 2014 21:55:58 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1402132155120.18671@blackhole.kfki.hu>
References: <CAKb7UvhsLi2Sv4SWA2nVTgoFV8dzrY=3R1-SUk9D-aa0VdizSA@mail.gmail.com> <alpine.DEB.2.10.1402131117120.16734@blackhole.kfki.hu> <CAHA+R7MeEEfqz-7RhCUjsoWPx_BKHVXFV3Y32xjf0B1WwjNdRQ@mail.gmail.com> <20140213184254.GF14175@macbook.localnet>
 <CAKb7UvjdPco0zrP9Ry4mPv40r-bnfNgKEfwcOvJb4JU-5XcTaw@mail.gmail.com> <20140213195908.GK25153@breakpoint.cc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ilia Mirkin <imirkin@alum.mit.edu>,
	Patrick McHardy <kaber@trash.net>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Vitaly Lavrov <lve@guap.ru>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140213195908.GK25153@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Feb 2014, Florian Westphal wrote:

> Ilia Mirkin <imirkin@alum.mit.edu> wrote:
> > > Maybe printing "using protocol version X" will make it appear less like
> > > a debugging message referring to packet contents or something similar.
> > 
> > With pr_info it'll still appear in dmesg, and it'll still be "random
> > non-sensical message appears over and over in dmesg" type of
> > situation, to the vast majority of users. Do we need a print every
> > time someone creates a new tcp connection too? I'm still not totally
> > clear on the cause of this message getting printed, but I was seeing
> > it a whole bunch in my configuration...
> 
> Yes, because it erronously got moved into the netns init function.
> 
> And thats what causes the spew.  Moving it back into module init
> function should be enough.

Florian has got right, that'd be the best.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
