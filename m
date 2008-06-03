From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH] [UDPv6] Possible dst leak in udpv6_sendmsg.
Date: Tue, 03 Jun 2008 15:50:45 +0400
Message-ID: <1212493845.6499.29.camel@iris.sw.ru>
References: <1212491322-9161-1-git-send-email-den@openvz.org>
	 <20080603.203532.39634783.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19481 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753684AbYFCLvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 07:51:02 -0400
In-Reply-To: <20080603.203532.39634783.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-06-03 at 20:35 +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> In article <1212491322-9161-1-git-send-email-den@openvz.org> (at Tue,=
  3 Jun 2008 15:08:42 +0400), "Denis V. Lunev" <den@openvz.org> says:
>=20
> > ip6_sk_dst_lookup returns held dst entry. It should be released on =
all paths
> > beyond this point. Add missed release when up->pending is set.
>=20
> Which kernel are you refering?
The patch is made against current net-2.6 tree, though all kernels are
affected, starting at least RHEL5

> And, would you please take a look at ipv4 side as well?

ipv4 is ok, the code looks the same but there is an ip_rt_put at the
out: label.

