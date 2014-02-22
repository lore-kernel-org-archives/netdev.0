From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Fri, 21 Feb 2014 17:40:50 -0800
Message-ID: <CAB=NE6XBcpOkktvEcGh=c9tTfAJjrnGWGDN9GmG-n+cx83-LLQ@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
 <1392433180-16052-3-git-send-email-mcgrof@do-not-panic.com>
 <1392668638.21106.5.camel@dcbw.local> <CAB=NE6XGBp1RwO63W0ac6tTr9JcRM9TB9sap4pa+8PMWwjxu6g@mail.gmail.com>
 <1392828325.21976.6.camel@dcbw.local> <CAB=NE6VpUqwNNY4pgbS6du2VsZ6dH0TzQYXmiw6GGN-EiOsV6g@mail.gmail.com>
 <53050244.1020106@citrix.com> <CAB=NE6VswYVF1BOM+vwEh3MaX7sh0gvLqz0U0JoEFDS-EzO9Pg@mail.gmail.com>
 <53074E6C.5080702@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53074E6C.5080702@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 21, 2014 at 5:02 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> Check this how current Xen scripts does routed networking:
>
> http://wiki.xen.org/wiki/Xen_Networking#Associating_routes_with_virtual_devices
>
> Note, there are no bridges involved here! As the above page says, the
> backend has to have IP address, maybe it's not true anymore. I'm not too
> familiar with this setup too, I've used it only once.

Thanks, in such case I do think actually adding a bridge, adding the
backend interface to it, and then adding a route to the front end IP
would suffice to cover that case, but I'm pretty limited with test
devices so would appreciate if someone with a setup like that can test
it as an alternative. Please recall that the possible gains here
should be pretty significant in terms of simplification. And of
course, I still also haven't had time / systems to test the NAT
case...

  Luis
