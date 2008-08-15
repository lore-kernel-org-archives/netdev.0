From: Artem Bityutskiy <dedekind@infradead.org>
Subject: Re: [PATCH] Remove duplicated unlikely() in IS_ERR()
Date: Fri, 15 Aug 2008 15:16:07 +0300
Message-ID: <1218802567.3095.1.camel@sauron>
References: <48A52D69.1040501@miraclelinux.com>
Reply-To: dedekind@infradead.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: christof.schmitt@de.ibm.com, yoshfuji@linux-ipv6.org,
	linux-mtd@lists.infradead.org, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org
To: Hirofumi Nakagawa <hnakagawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:64128 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbYHOMSj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 08:18:39 -0400
In-Reply-To: <48A52D69.1040501@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Fri, 2008-08-15 at 16:16 +0900, Hirofumi Nakagawa wrote:
> Hi
> Some drivers have duplicated unlikely() macros.
> IS_ERR() already has unlikely() in itself.
> This patch cleans up such pointless codes although there is no real
> effect on the kernel's behaviour.

please, send an UBIFS-only patch and I'll put it to ubifs-2.6.git,
thanks.

--=20
Best regards,
Artem Bityutskiy (=D0=91=D0=B8=D1=82=D1=8E=D1=86=D0=BA=D0=B8=D0=B9 =D0=90=
=D1=80=D1=82=D1=91=D0=BC)

