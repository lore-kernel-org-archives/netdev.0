From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4: Revert "mlx4: set maximal number
 of default RSS queues"
Date: Wed, 1 Jan 2014 23:50:33 +0200
Message-ID: <CAJZOPZ++ETzuttO9_ZTy6Atx6=wKyhXUhxyQHj2Ed5nTUBNC0A@mail.gmail.com>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
	<1388581537-4810-3-git-send-email-amirv@mellanox.com>
	<979A8436335E3744ADCD3A9F2A2B68A52AF21A1A@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:44406 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644AbaAAVue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 16:50:34 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so13513430pde.20
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 13:50:33 -0800 (PST)
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AF21A1A@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 1, 2014 at 8:46 PM, Yuval Mintz <yuvalmin@broadcom.com> wrote:
>
> [...] If you believe this is a better default (or some relaxation will be, e.g.,  16 instead of 8),  why not set it as default for ALL multi-queue networking drivers?

Going back to your original commit 16917b87a "net-next: Add
netif_get_num_default_rss_queues" I am still not clear why we want

1. why we want a common default to all MQ devices?

2. why this default has to be hard coded and not derived e.g from the
number of cores or alike attribute of the system?

Can you please elaborate?

Or.
