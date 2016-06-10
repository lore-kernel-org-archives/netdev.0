From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [net v3] veth: advertise peer link once both links are tied
 together
Date: Fri, 10 Jun 2016 09:20:58 -0400 (EDT)
Message-ID: <1764704950.51133004.1465564858359.JavaMail.zimbra@redhat.com>
References: <574C6095.9050804@6wind.com> <1464623917-11536-1-git-send-email-vincent@bernat.im> <87bn3n358j.fsf@zoro.exoscale.ch> <574C69DE.3050305@6wind.com> <m3fusyg2pi.fsf@neo.luffy.cx> <574D56A0.3090606@6wind.com> <694175272.49661350.1465417849878.JavaMail.zimbra@redhat.com> <575ABD55.7020202@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vincent Bernat <vincent@bernat.im>,
	"David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: nicolas dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:50626 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932783AbcFJNVE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 09:21:04 -0400
In-Reply-To: <575ABD55.7020202@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> From: "Nicolas Dichtel" <nicolas.dichtel@6wind.com>
> To: "Lance Richardson" <lrichard@redhat.com>, "Vincent Bernat" <vince=
nt@bernat.im>
> Cc: "David S. Miller" <davem@davemloft.net>, "Vijay Pandurangan" <vij=
ayp@vijayp.ca>, "Paolo Abeni"
> <pabeni@redhat.com>, netdev@vger.kernel.org
> Sent: Friday, June 10, 2016 9:15:01 AM
> Subject: Re: [net v3] veth: advertise peer link once both links are t=
ied together
>=20
> Le 08/06/2016 22:30, Lance Richardson a =C3=A9crit :
> [snip]
> > I've been pondering how to fix this very problem off-and-on for a f=
ew
> > months
> > now, without having arrived at any solution that was particularly
> > satisfying.
> >=20
> > The main constraints I've been trying to meet are:
> >    - User-space should be informed of veth pairing for both peers.
> >    - RTM_NEWLINK messages should not refer to interfaces that haven=
't
> >      been announced to user-space via previous RTM_NEWLINK messages=
=2E
> >    - The first (and only the first) RTM_NEWLINK message for a given
> >      interface should have ifi_changes set to ~0U, subsequent RTM_N=
EWLINK
> >      messages should have ifi_changes set to reflect the flags that
> >      have changed.
> >=20
> > This is the closest I've come to a satisfactory solution, it does m=
eet
> > the above constraints but still seems a little unnatural to me:
> The patch looks good to me. Can you submit it formally?
>=20

Will post in a bit, thanks!

  Lance
