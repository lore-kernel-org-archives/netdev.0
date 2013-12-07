From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 2/2] ipv6 addrconf: introduce IFA_F_MANAGETEMPADDR to tell kernel to manage temporary addresses
Date: Sat, 7 Dec 2013 04:36:16 +0100
Message-ID: <20131207033616.GB16799@order.stressinduktion.org>
References: <1386319522-2102-1-git-send-email-jiri@resnulli.us> <1386319522-2102-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM,
	fx.lebail@yahoo.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38013 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab3LGDgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 22:36:18 -0500
Content-Disposition: inline
In-Reply-To: <1386319522-2102-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri!

On Fri, Dec 06, 2013 at 09:45:22AM +0100, Jiri Pirko wrote:
> Creating an address with this flag set will result in kernel taking c=
are
> of temporary addresses in the same way as if the address was created =
by
> kernel itself (after RA receive). This allows userspace applications
> implementing the autoconfiguration (NetworkManager for example) to
> implement ipv6 addresses privacy.

I think we should follow up on something Fran=C3=A7ois-Xavier Le Bail p=
roposed
here:

http://patchwork.ozlabs.org/patch/294029/

In general I like the idea, and I also agree with David, we should disa=
ble
it by default. But this would be beneficial to NetworkManager to not ne=
ed
to set temp_addresses to 2 to have them used by default. I guess a netl=
ink
api and a per-interface flag would be the easiest thing for NM to handl=
e?

Greetings,

  Hannes
