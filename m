From: Marek Vasut <marek.vasut@gmail.com>
Subject: Re: [PATCH] pxaficp-ir - remove incorrect net_device_ops
Date: Mon, 24 Aug 2009 14:47:03 +0200
Message-ID: <200908241447.03117.marek.vasut@gmail.com>
References: <a4423d670908231055o2bb65fe0le2c33fe94b660b38@mail.gmail.com> <20090824043831.GA2473@orion> <20090823.225743.135339409.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: a.beregalov@gmail.com, eric.y.miao@gmail.com,
	linux-arm-kernel@lists.arm.linux.org.uk, linux@arm.linux.org.uk,
	samuel@sortiz.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:54804 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbZHXMr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 08:47:26 -0400
Received: by bwz19 with SMTP id 19so1425239bwz.37
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2009 05:47:27 -0700 (PDT)
In-Reply-To: <20090823.225743.135339409.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne Po 24. srpna 2009 07:57:43 David Miller napsal(a):
> From: Alexander Beregalov <a.beregalov@gmail.com>
> Date: Mon, 24 Aug 2009 08:38:31 +0400
>
> > Subject: [PATCH] pxaficp-ir - remove incorrect net_device_ops
> >
> > This patch fixes broken pxaficp-ir. The problem was in incorrect
> > net_device_ops being specified which prevented the driver from
> > operating. The symptoms were:
> >  - failing ifconfig for IrLAN, resulting in
> > 	SIOCSIFFLAGS: Cannot assign requested address
> >  - irattach working for IrCOMM, but the port stayed disabled
> >
> > Moreover this patch corrects missing sysfs device link.
> >
> > Signed-off-by: Marek Vasut <marek.vasut@gmail.com>
>
> Applied, thanks.

Thank you.
