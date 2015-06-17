From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/3 v4] changes to make ipv4 routing table aware
 of next-hop link status
Date: Wed, 17 Jun 2015 21:52:11 +0200
Message-ID: <5581CFEB.3010000@6wind.com>
References: <1434386001-1157-1-git-send-email-gospo@cumulusnetworks.com> <55819ACC.3010702@6wind.com> <20150617191012.GJ588@gospo.home.greyhouse.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:33467 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbbFQTwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 15:52:14 -0400
Received: by wgez8 with SMTP id z8so45652987wge.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 12:52:13 -0700 (PDT)
In-Reply-To: <20150617191012.GJ588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/06/2015 21:10, Andy Gospodarek a =E9crit :
> On Wed, Jun 17, 2015 at 06:05:32PM +0200, Nicolas Dichtel wrote:
>> Le 15/06/2015 18:33, Andy Gospodarek a =E9crit :
>>> This series adds the ability to have the Linux kernel track whether=
 or
>>> not a particular route should be used based on the link-status of t=
he
>>> interface associated with the next-hop.
>>>
>>> Before this patch any link-failure on an interface that was serving=
 as a
>>> gateway for some systems could result in those systems being isolat=
ed
>> >from the rest of the network as the stack would continue to attempt=
 to
>>> send frames out of an interface that is actually linked-down.  When=
 the
>>> kernel is responsible for all forwarding, it should also be respons=
ible
>>> for taking action when the traffic can no longer be forwarded -- th=
ere
>>> is no real need to outsource link-monitoring to userspace anymore.
>>>
>>> This feature is only enabled with the new per-interface or ipv4 glo=
bal
>>> sysctls called 'ignore_routes_with_linkdown'.
>>>
>>> net.ipv4.conf.all.ignore_routes_with_linkdown =3D 0
>>> net.ipv4.conf.default.ignore_routes_with_linkdown =3D 0
>>> net.ipv4.conf.lo.ignore_routes_with_linkdown =3D 0
>>> ...
>> Sorry for my late reply, but is it possible to advertise this sysctl=
 via the
>> netconf infra (grep NETCONFA_)?
> I would be happy to do that.  Do you see it as a requirement for this
> set to be accepted?
No, but it would be great to do it before net-next closes.

>
> I've got to add ipv6 support, so netconf support could also easily be
> added in the kernel and iproute2.
Ok.
