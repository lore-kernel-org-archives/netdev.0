From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/3 v4] changes to make ipv4 routing table aware
 of next-hop link status
Date: Wed, 17 Jun 2015 18:05:32 +0200
Message-ID: <55819ACC.3010702@6wind.com>
References: <1434386001-1157-1-git-send-email-gospo@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33600 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754802AbbFQQFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 12:05:35 -0400
Received: by wiwd19 with SMTP id d19so138405828wiw.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 09:05:34 -0700 (PDT)
In-Reply-To: <1434386001-1157-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/06/2015 18:33, Andy Gospodarek a =C3=A9crit :
> This series adds the ability to have the Linux kernel track whether o=
r
> not a particular route should be used based on the link-status of the
> interface associated with the next-hop.
>
> Before this patch any link-failure on an interface that was serving a=
s a
> gateway for some systems could result in those systems being isolated
> from the rest of the network as the stack would continue to attempt t=
o
> send frames out of an interface that is actually linked-down.  When t=
he
> kernel is responsible for all forwarding, it should also be responsib=
le
> for taking action when the traffic can no longer be forwarded -- ther=
e
> is no real need to outsource link-monitoring to userspace anymore.
>
> This feature is only enabled with the new per-interface or ipv4 globa=
l
> sysctls called 'ignore_routes_with_linkdown'.
>
> net.ipv4.conf.all.ignore_routes_with_linkdown =3D 0
> net.ipv4.conf.default.ignore_routes_with_linkdown =3D 0
> net.ipv4.conf.lo.ignore_routes_with_linkdown =3D 0
> ...
Sorry for my late reply, but is it possible to advertise this sysctl vi=
a the
netconf infra (grep NETCONFA_)?


Regards,
Nicolas
