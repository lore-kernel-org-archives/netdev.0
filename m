From: FengYu LeiDian <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH iproute2] ip xfrm: support 64bit kernel and 32bit userspace
Date: Fri, 28 Nov 2014 15:08:05 +0800
Message-ID: <54781F55.5040603@gmail.com>
References: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:56404 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaK1HKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 02:10:40 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so6291161pab.12
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 23:10:40 -0800 (PST)
In-Reply-To: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2014=C4=EA11=D4=C228=C8=D5 14:58, roy.qing.li@gmail.com =D0=B4=B5=
=C0:
> From: Li RongQing<roy.qing.li@gmail.com> =20
>=20
> The size of struct xfrm_userpolicy_info is 168 bytes for 64bit kernel=
, and
> 164 bytes for 32bit userspace because of the different alignment. and=
 lead
> to "ip xfrm" be unable to work.
>=20
> add a pad in struct xfrm_userpolicy_info, and enable it by set
> KERNEL_64_USERSPACE_32 to y


It's not easy to fix it like this.

Refer:
http://marc.info/?l=3Dlinux-netdev&m=3D139280143513650&w=3D2
http://thread.gmane.org/gmane.linux.network/157118/focus=3D157122
