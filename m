From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ip monitoring
Date: Thu, 22 Jan 2009 11:56:40 +1100
Message-ID: <20090122115640.55c69a0d@s6510>
References: <3f847c820901211618p476f3b71kbc994680d4a0a2e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?UmHDumwgSGVybsOhbmRleg==?= <rauhersu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54511 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbZAVA5S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 19:57:18 -0500
In-Reply-To: <3f847c820901211618p476f3b71kbc994680d4a0a2e8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Jan 2009 01:18:35 +0100
Ra=C3=BAl Hern=C3=A1ndez <rauhersu@gmail.com> wrote:

> Hi there,
>=20
> Just a quick question regarding ip monitoring: I am trying to develop
> a user space app which must be aware of changes related to ip
> management and link status (up, down, this-ip-has-been added,..). So
> far, I am trying to avoid polling the link/ip to notice these changes
> as I would like to be notified asynchronously.
>=20
> Is there any API/quick fix for user space apps to get that (I am
> trying to avoid any kernel development as well) ?
>=20
> Thx!
>=20
> Best regards,
> Raul
>=20

netlink api - look at netplugd or "ip monitor" source.
