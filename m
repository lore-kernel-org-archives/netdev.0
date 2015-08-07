From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: netlink: add support for vlan_filtering attribute
Date: Fri, 7 Aug 2015 19:28:23 +0300
Message-ID: <BD6CDFE9-7FCC-461E-A585-6F477AA99B14@cumulusnetworks.com>
References: <1438964658-2904-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36529 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945925AbbHGQ21 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 12:28:27 -0400
Received: by wicgj17 with SMTP id gj17so67879785wic.1
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2015 09:28:26 -0700 (PDT)
In-Reply-To: <1438964658-2904-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 7, 2015, at 7:24 PM, Nikolay Aleksandrov <razor@blackwall.org>=
 wrote:
>=20
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>=20
> This patch adds the ability to toggle the vlan filtering support via
> netlink. Since we're already running with rtnl in .changelink() we do=
n't
> need to take any additional locks.
>=20
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> I'll post the iproute2 patch if this one gets accepted.
>=20

Uh, I wanted to post a version that returns an error when vlan filterin=
g isn=E2=80=99t supported
instead of always succeeding. So please drop this patch, I=E2=80=99ll p=
ost a v2 with that change
so the user will know if vlan filtering was actually enabled.
