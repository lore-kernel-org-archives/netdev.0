From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net v2] ipv6: fix rtnl locking in setsockopt for anycast
 and multicast
Date: Fri, 5 Sep 2014 12:23:37 -0700
Message-ID: <CAHA+R7NSu=wjGsmLapjM4Mbk_oeZ07P+yN0b982otvjoW2jodA@mail.gmail.com>
References: <20140901210520.GB25543@kria>
	<1409610378.21965.52.camel@localhost>
	<20140902082929.GA8483@kria>
	<20140905.115305.809714259412705649.davem@davemloft.net>
	<CAHA+R7M1qd5g1ta=YFqefgXDf1EfF2_VsJGUvH6Dd+ttnHc_VQ@mail.gmail.com>
	<1409944376.5306.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Tommi Rantala <tt.rantala@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	trinity@vger.kernel.org, Dave Jones <davej@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409944376.5306.9.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 5, 2014 at 12:12 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> What games are you playing? You know how patches are processed by David
> and I even let him the choice by pointing out a problem in your patch so
> that you could an update and send v2.

I assume David goes over all the discussion before applying any patch.
So in the original discussion, obviously I disagree with your point on RCU,
and sent my own version.

I do understand David may miss something due to massive emails in
this list, but you make no point here nor I understand your broken English
"let him the choice...".

>
> I really feel miffed about your behavior!
>

I SEE. Please do redirect my email to your /dev/null. Thanks a lot!

> Anyway, I saw the hunk adding the return -ENODEV and didn't see any
> problems with it. Sure it might be better if it would gone into a
> separate patch. Can you elaborate what problems you see?
>

Yes, it should be not in this patch at the very very least.
