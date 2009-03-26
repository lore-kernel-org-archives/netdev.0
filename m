From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC v2 5/7] net: netfilter conntrack - add per-net
	functionality for TCP protocol
Date: Thu, 26 Mar 2009 18:37:47 +0300
Message-ID: <20090326153747.GB7950@localhost>
References: <20090311205706.141086138@gmail.com> <20090311210817.688725782@gmail.com> <20090316205825.GK7551@localhost> <49CB9BB6.3040004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, daniel.lezcano@free.fr,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49CB9BB6.3040004@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Patrick McHardy - Thu, Mar 26, 2009 at 04:13:58PM +0100]
> Cyrill Gorcunov wrote:
>> Here is an updated version which uses iterative assignment
>> of sysctl data. Please review.
>> ---
>>
>> From: Cyrill Gorcunov <gorcunov@openvz.org>
>> Subject: [RFC v2 5/7] net: netfilter conntrack - add per-net functionality for TCP protocol
>>
>> Module specific data moved into per-net site and being allocated/freed
>> during net namespace creation/deletion. For this reason module_init/exit
>> calls added.
>
>
> I guess this isn't going to get any prettier :) Could you please
> send me the latest version of the missing patches against the current
> nf-next tree?
>

Yes, no problem, wait a bit please.

Btw, I think the bestest way (and surely more clean)
would be to use some new form of the sysctl templates.

But I didn't find such a form of writting which would
sutisfy me. Since you said those enums are written in
stone it's safe to use iterative fasion indeed but
as I see you found them not that "pretty" too :)

On the other hand -- if per-net initialization is not
that critical in speed (ie some speed could be sacrificed
for the code clarity -- I could play with those templates
maybe). Just a thought.

        Cyrill
