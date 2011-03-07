From: Roland Dreier <roland@purestorage.com>
Subject: Re: [PATCH 13/17] mlx4: Add blue flame support for kernel consumers
Date: Mon, 7 Mar 2011 13:07:48 -0800
Message-ID: <AANLkTi=uRL2GAb7CBqJiVUuXTgpX_w7=3PZ3JdmL_+jj@mail.gmail.com>
References: <4D74B0D2.1000907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eli@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog106.obsmtp.com ([74.125.245.80]:55823 "HELO
	na3sys010aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752994Ab1CGVIK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 16:08:10 -0500
Received: by mail-vx0-f171.google.com with SMTP id 40so4834898vxc.30
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 13:08:08 -0800 (PST)
In-Reply-To: <4D74B0D2.1000907@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2011 at 2:17 AM, Yevgeny Petrilin
<yevgenyp@mellanox.co.il> wrote:
> + =A0 =A0 =A0 if (map_bf_area(dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mlx4_dbg(dev, "Kernel support for blue =
flame is not available for kernels < 2.6.28\n");

This seems like a really bad error message.  Can map_bf_area() actually=
 fail?

 - R.
