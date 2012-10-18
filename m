From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] net/core: support runtime PM on net_device
Date: Thu, 18 Oct 2012 15:05:48 -0400 (EDT)
Message-ID: <20121018.150548.538241834379627262.davem@davemloft.net>
References: <CACVXFVPu1m3CJaFavW9eaU3Z850q+x1N_Yo7tri1UTFpgfYVXQ@mail.gmail.com>
	<87obk080us.fsf@nemi.mork.no>
	<CACVXFVMmSFHYU-sNHRM7g_8U6mjbdbE+bNPxM-F8iAB=4WudRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, rjw@sisk.pl, oneukum@suse.de,
	stern@rowland.harvard.edu, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: ming.lei@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab2JRTFv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 15:05:51 -0400
In-Reply-To: <CACVXFVMmSFHYU-sNHRM7g_8U6mjbdbE+bNPxM-F8iAB=4WudRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ming Lei <ming.lei@canonical.com>
Date: Thu, 18 Oct 2012 20:55:58 +0800

> On Thu, Oct 18, 2012 at 7:40 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>>
>> Because bugs are supposed to be fixed and not hidden?
>=20
> OK, now let's discuss solution for the problem which should be
> clear and be solved.
>=20
> The 1st one is to do it by this patch, or rule out some ioctl cmd
> which needn't wakeup device.
>=20
> The second one is to fix ioctl one by one in each driver.
>=20
> Any other solution?

The second is clearly the correct way to handle these issues.

Drivers need to be aware when their drivers ops are called whether
they can safely access the device or not.

I'm not applying this patch.
