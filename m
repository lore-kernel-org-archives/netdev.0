From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Mon, 24 Feb 2014 12:33:35 -0800
Message-ID: <CAB=NE6Uf63XAAi_Sy5iSy2sjfNdWd9QsPECMBVBrUX9z4_L5-g@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
 <1392433180-16052-3-git-send-email-mcgrof@do-not-panic.com>
 <1392668638.21106.5.camel@dcbw.local> <CAB=NE6XGBp1RwO63W0ac6tTr9JcRM9TB9sap4pa+8PMWwjxu6g@mail.gmail.com>
 <1392828325.21976.6.camel@dcbw.local> <CAB=NE6VpUqwNNY4pgbS6du2VsZ6dH0TzQYXmiw6GGN-EiOsV6g@mail.gmail.com>
 <1392857777.22693.14.camel@dcbw.local> <CAB=NE6Xvqcdje5OSxjzTRa3wv-vZHr+MJHY86ZCfFXU2Lpzi8Q@mail.gmail.com>
 <1393266120.8041.19.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393266120.8041.19.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 24, 2014 at 10:22 AM, Dan Williams <dcbw@redhat.com> wrote:
> My use-case would simply be to have an analogue for the disable_ipv6
> case.  In the future I expect more people will want to disable IPv4 as
> they move to IPv6.  If you don't have something like disable_ipv4, then
> there's no way to ensure that some random program or something doesn't
> set up IPv4 stuff that you don't want.
>
> Same thing for IPv6; some people really don't want IPv6 enabled on an
> interface no matter what; they don't want an IPv6LL address assigned,
> they don't want kernel SLAAC, they want to ensure that *nothing*
> IPv6-related gets done for that interface.  The same can be true for
> IPv4, but we don't have a way of doing that right now.

I'll add this to my queue.

  Luis
