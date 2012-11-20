From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RESEND PATCH net-next 1/1] sit: allow to configure 6rd tunnels
 via netlink
Date: Tue, 20 Nov 2012 09:17:48 -0800
Message-ID: <20121120091748.359d95db@nehalam.linuxnetplumber.net>
References: <20121120.033405.490869980095149376.davem@davemloft.net>
	<1353400905-28335-1-git-send-email-nicolas.dichtel@6wind.com>
	<20121120090113.47ce16b5@nehalam.linuxnetplumber.net>
	<50ABB9CD.6080506@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39150 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807Ab2KTRSy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 12:18:54 -0500
In-Reply-To: <50ABB9CD.6080506@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Nov 2012 18:11:41 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Le 20/11/2012 18:01, Stephen Hemminger a =E9crit :
> > On Tue, 20 Nov 2012 09:41:45 +0100
> > Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> >
> >> This patch add the support of 6RD tunnels management via netlink.
> >> Note that netdev_state_change() is now called when 6RD parameters =
are updated.
> >>
> >> 6RD parameters are updated only if there is at least one 6RD attri=
bute.
> >>
> >> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >> ---
> >>   include/uapi/linux/if_tunnel.h |   4 ++
> >>   net/ipv6/sit.c                 | 149 +++++++++++++++++++++++++++=
+++++++-------
> >>   2 files changed, 128 insertions(+), 25 deletions(-)
> >>
> >
> > Ok, but iproute2 git is currently for 3.6
> > Please resubmit when 3.7 is finished during 3.8 merge window.
> Hmm, not sure to understand. This is a kernel patch.


I assumed you would need a user space part as well.
