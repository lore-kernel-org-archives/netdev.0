From: Daniel Robbins <drobbins@funtoo.org>
Subject: Re: [Bridge] [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Tue, 12 May 2009 11:07:14 -0600
Message-ID: <de7adc5e0905121007t74ba52e2j9a98b998540e7df9@mail.gmail.com>
References: <20090511114639.440944109@openvz.org>
	 <de7adc5e0905112230r60254113t6b31d8114d141be@mail.gmail.com>
	 <aa79d98a0905112319k6bc19ebk60a6458165b8c0a1@mail.gmail.com>
	 <de7adc5e0905120002o7f19a1eepe0397d698c08ce97@mail.gmail.com>
	 <20090512162432.GA12820@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, xemul@openvz.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:58078 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbZELRHO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 13:07:14 -0400
Received: by qw-out-2122.google.com with SMTP id 5so77209qwd.37
        for <netdev@vger.kernel.org>; Tue, 12 May 2009 10:07:15 -0700 (PDT)
In-Reply-To: <20090512162432.GA12820@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2009 at 10:24 AM, Cyrill Gorcunov <gorcunov@gmail.com> =
wrote:
> So, Daniel, i think the right question is -- do I ever need to
> configure/setup bridge remotely? I suppose yes, it happens.
> (at least I had a machine with lack of input device except a few
> =C2=A0NICs :-)

Aha, yes it would be useful in that case :)

So is the idea that you use via_phys_dev *temporarily* when
configuring the bridge, then you get it set up the way you want, and
then maybe you reboot the machine, and this time leave via_phys_dev
off? Or are there certain cases you can envision where you might want
this enabled permanently?

> This feature already was in OpenVZ 2.6.24 kernel. I'm more intirestin=
g in
> usefulness of this feature for the mainline. (in short -- we use it f=
or bridging
> VEs with eth0 as a master device so all works without needing to
> reconfigure routing table). Moreover, since bridge already support
> namespacing the feature could be usefull for lxc as well (though
> didn't check to be fair).

But not in the OpenVZ 2.6.27-briullov kernel yet, at least the one I'm
running :)

> That is why it's RFC so people could decide should it be included
> into mainline or not. Worth it so or not.

If it is accepted into mainline, be sure to send Stephen some
documentation on this feature so he can add it to the net:bridge docs.
When features like this aren't documented, no one knows how to use
them. I just ran into this issue with the 2.6.27+ "sticky" bridge MAC
feature. I'd also be willing to help keeping the bridge docs
up-to-date. Please let me know if you or Stephen want me to do this.
Bridging is really important for OpenVZ and other
container/paravirtualization technologies so keeping docs up-to-date
is becoming more important. It can be useful to have a
non-kernel-developer like me document the functionality.

Best Regards,

Daniel
