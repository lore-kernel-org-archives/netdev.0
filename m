From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 4/5] vxlan: add scope_id support for ll addr
Date: Sun, 21 Apr 2013 22:57:18 +0800
Message-ID: <1366556238.23100.19.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-5-git-send-email-amwang@redhat.com>
	 <OFA1761298.DF396ECD-ON85257B52.003AE2CA-85257B52.003DBDAB@us.ibm.com>
	 <1366552033.23100.16.camel@cr0> <8738ukosar.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753744Ab3DUO7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 10:59:11 -0400
In-Reply-To: <8738ukosar.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-04-21 at 16:46 +0200, Bj=C3=B8rn Mork wrote:
> struct vxlan_addr *rip =3D &vxlan->default_dst.remote_ip;
>=20
> rip->va_sin.sin_addr.s_addr
> rip->va_sin6.sin6_addr=20

I don't see any difference between this with:

vxlan->default_dst.remote_ip.va_sin.sin_addr.s_addr
vxlan->default_dst.remote_ip.va_sin6.sin6_addr

except making two lines shorter... People still have to go into 5 level=
s
to get the final field.
