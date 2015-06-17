From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3 v4] changes to make ipv4 routing table aware
 of next-hop link status
Date: Wed, 17 Jun 2015 16:25:27 -0400
Message-ID: <20150617202526.GK588@gospo.home.greyhouse.net>
References: <1434386001-1157-1-git-send-email-gospo@cumulusnetworks.com>
 <55819ACC.3010702@6wind.com>
 <20150617191012.GJ588@gospo.home.greyhouse.net>
 <5581CFEB.3010000@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:35916 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbbFQUZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 16:25:30 -0400
Received: by qgal13 with SMTP id l13so19487912qga.3
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 13:25:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5581CFEB.3010000@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2015 at 09:52:11PM +0200, Nicolas Dichtel wrote:
> Le 17/06/2015 21:10, Andy Gospodarek a =E9crit :
> >On Wed, Jun 17, 2015 at 06:05:32PM +0200, Nicolas Dichtel wrote:
> >>Le 15/06/2015 18:33, Andy Gospodarek a =E9crit :
> >>>This series adds the ability to have the Linux kernel track whethe=
r or
> >>>not a particular route should be used based on the link-status of =
the
> >>>interface associated with the next-hop.
> >>>
> >>>Before this patch any link-failure on an interface that was servin=
g as a
> >>>gateway for some systems could result in those systems being isola=
ted
> >>>from the rest of the network as the stack would continue to attemp=
t to
> >>>send frames out of an interface that is actually linked-down.  Whe=
n the
> >>>kernel is responsible for all forwarding, it should also be respon=
sible
> >>>for taking action when the traffic can no longer be forwarded -- t=
here
> >>>is no real need to outsource link-monitoring to userspace anymore.
> >>>
> >>>This feature is only enabled with the new per-interface or ipv4 gl=
obal
> >>>sysctls called 'ignore_routes_with_linkdown'.
> >>>
> >>>net.ipv4.conf.all.ignore_routes_with_linkdown =3D 0
> >>>net.ipv4.conf.default.ignore_routes_with_linkdown =3D 0
> >>>net.ipv4.conf.lo.ignore_routes_with_linkdown =3D 0
> >>>...
> >>Sorry for my late reply, but is it possible to advertise this sysct=
l via the
> >>netconf infra (grep NETCONFA_)?
> >I would be happy to do that.  Do you see it as a requirement for thi=
s
> >set to be accepted?
> No, but it would be great to do it before net-next closes.
Will do.

>=20
> >
> >I've got to add ipv6 support, so netconf support could also easily b=
e
> >added in the kernel and iproute2.
> Ok.
