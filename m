From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH for-next 2/2] net/mlx5: Update mlx5_ifc hardware features
Date: Tue, 12 Apr 2016 12:13:12 +0300
Message-ID: <CAJ3xEMiu3o=yMABh1N7w8mDV4yddE1zk5FYoHHHB02tDhOqzHw@mail.gmail.com>
References: <1460405422-8654-1-git-send-email-saeedm@mellanox.com>
	<1460405422-8654-3-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMghu7ZB0YM8j_YJihpuNnDzOY2LU9-cTHwoWiBeYY7VPA@mail.gmail.com>
	<CALzJLG-PxUz9ov+cv4uiNSGpuxy0s9KamTvamV_g72SctqdhFA@mail.gmail.com>
	<CAJ3xEMhorMRsxtawjim9zoBn-zzoDXcMAJfHUqCZBNUbOKrMJA@mail.gmail.com>
	<20160412051537.GD25242@leon.nu>
	<CAJ3xEMijYrLvSmbNZp0B6AXqKGozz1rdZ58SCUP_09zOB6-2gQ@mail.gmail.com>
	<20160412060117.GA24649@leon.nu>
	<CALzJLG8fXPLQ7tj2Nc7NbGpu4EuNoXTE+w8tDkwQ2F_AqgDtLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Leon Romanovsky <leon@leon.nu>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38620 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756518AbcDLJNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 05:13:13 -0400
In-Reply-To: <CALzJLG8fXPLQ7tj2Nc7NbGpu4EuNoXTE+w8tDkwQ2F_AqgDtLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 12, 2016 at 10:40 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:

> Why would you break down this patch to many when no matter what you
> do, at the end it would look the same ?
> As Leon mentioned we MLNX maintainers prefer to update this file at
> once when possible.

See my response to Leon. It happened to me many times in code review
that people gave
me patches that open X fields in the IFC file and their code used Y <<
X fields. I don't
want the IFC file to have even one unused field, and I think the
correct way to do that
is have both the IFC file and the driver changes in the same series. I
understand the trend
to have zero-conflicts, lets try that. Did you make sure all exposed
IFC fields are used?

Or.
