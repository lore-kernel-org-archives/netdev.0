From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter: Replace explicit NULL comparisons
Date: Mon, 10 Apr 2017 13:51:44 +0200
Message-ID: <20170410115144.GA2155@salvia>
References: <20170408172113.GA9352@arushi-HP-Pavilion-Notebook>
 <nycvar.YFH.7.76.1704082020530.14011@n3.vanv.qr>
 <20170408201438.GC2679@salvia>
 <CA+XqjF_8=+GB7oq6wKoxk_+FfPeni+tLaVMAE6k6tP-KOOEi6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@inai.de>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+XqjF_8=+GB7oq6wKoxk_+FfPeni+tLaVMAE6k6tP-KOOEi6Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 09, 2017 at 09:12:18AM +0530, Arushi Singhal wrote:
> On Sun, Apr 9, 2017 at 1:44 AM, Pablo Neira Ayuso <pablo@netfilter.org>
> wrote:
> 
> > On Sat, Apr 08, 2017 at 08:21:56PM +0200, Jan Engelhardt wrote:
> > > On Saturday 2017-04-08 19:21, Arushi Singhal wrote:
> > >
> > > >Replace explicit NULL comparison with ! operator to simplify code.
> > >
> > > I still wouldn't do this, for the same reason as before. Comparing to
> > > NULL explicitly more or less gave an extra guarantee that the other
> > > operand was also a pointer.
> >
> > Arushi, where does it say in the coding style that this is prefered?
> 
> This is reported by checkpatch.pl script.

I don't find it in the coding style. I think this is what it stands as
preference in this case IMO. Otherwise, it would be good to get the
kernel coding style document in sync with it, including the reason why
this way to express thing is cleaner. We have to justify the changes.
