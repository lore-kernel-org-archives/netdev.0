From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize
	modifications
Date: Fri, 5 Feb 2010 13:23:01 +0200
Message-ID: <b6fcc0a1002050323t4fe1edd1n6aca6fd5a9ba6bad@mail.gmail.com>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>
	 <4B6AFE22.20304@trash.net> <20100204194744.GA4185@x200>
	 <4B6BEC23.8020101@trash.net> <4B6BFE29.1040204@trash.net>
	 <b6fcc0a1002050319p2ba0ff30y4bc8bdba08ff65d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jonathan@jonmasters.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <b6fcc0a1002050319p2ba0ff30y4bc8bdba08ff65d9@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 5, 2010 at 1:19 PM, Alexey Dobriyan <adobriyan@gmail.com> w=
rote:
> On Fri, Feb 5, 2010 at 1:16 PM, Patrick McHardy <kaber@trash.net> wro=
te:
>> OK testing looks fine, although I'm quite surprised that its actuall=
y
>> possible to change module parameters from within non-init namespaces=
=2E
>> How is this supposed to work at all? I don't see how sysfs could
>> possibly provide a network namespace context ...
>
>
> You can do in write hook
>
> =A0 =A0if (!net_eq(current->nsproxy->net_ns, &init_net))
> =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;

-EPERM of course.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
