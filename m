From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6 addrconf: source address selection, Rule 7: Prefer temporary addresses (RFC 6724)
Date: Tue, 26 Nov 2013 20:26:00 +0100
Message-ID: <20131126192600.GB20630@order.stressinduktion.org>
References: <1385396205-6105-1-git-send-email-fx.lebail@yahoo.com> <20131126085404.GA20630@order.stressinduktion.org> <5294E13B.8010108@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fx.lebail@yahoo.com, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, dcbw@redhat.com,
	jiri@resnulli.us
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39992 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388Ab3KZT0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 14:26:01 -0500
Content-Disposition: inline
In-Reply-To: <5294E13B.8010108@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 26, 2013 at 06:58:19PM +0100, Florent Fourcot wrote:
> >> The RFC 6724 change the default recommendation for source address selection
> >> Rule 7 to prefer temporary addresses rather than public addresses,
> >> while providing an administrative override.
> >>
> >> The administrative override is based on the prefer_src_public sysctl.
> > 
> > I like the idea and it could be useful in addition to the new
> > IFA_F_MANAGETEMPADDR flag which should show up any time soon.
> > 
> 
> I like the principle of the idea too, but is it acceptable to break the
> user space compatibility?
> If the patch is accepted, someone with the value "1" in use_tempaddr
> will have a big surprise with a newer kernel  (I do not see any use case
> to set this option to 1, but maybe...).

Yeah, I thought about that, too. But as new kernels would ship with a default
policy of prefer those temporary addresses I thought it would be ok.
