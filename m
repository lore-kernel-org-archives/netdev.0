From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: re: macvtap: convert to SKB paged frag API.
Date: Tue, 20 Sep 2011 11:05:28 +0100
Message-ID: <1316513129.3891.8.camel@zakaz.uk.xensource.com>
References: <20110920091724.GA11100@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:12654 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582Ab1ITKFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 06:05:32 -0400
In-Reply-To: <20110920091724.GA11100@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-20 at 10:17 +0100, Dan Carpenter wrote:
> Hi Ian,
>=20
> There is a problem in d1b08284ade "macvtap: convert to SKB paged frag
> API."  It removes the initialization of "f" in zerocopy_sg_from_iovec=
()
> which breaks it and causes a compile warning:
> drivers/net/macvtap.c:509:5: warning: =E2=80=98f=E2=80=99 may be used=
 uninitialized
> 	in this function [-Wuninitialized]

Not just a warning but an actual bug -- I'll post a patch.

Thanks for the heads up!

Ian.
