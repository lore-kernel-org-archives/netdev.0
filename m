From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] drivers: net: ethernet: mellanox: mlx4: let mlx4 depend
 on SMP
Date: Sat, 17 May 2014 22:55:34 +0300
Message-ID: <CAJZOPZJN9YG2uAw0rSDkU0rQG=0FFDgSMnFDHpWS6hwZEqdwfA@mail.gmail.com>
References: <5376F2F8.3010603@gmail.com>
	<20140517.013655.349586284786993619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: gang.chen.5i5j@gmail.com, Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>, gxt@mprc.pku.edu.cn,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:65283 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbaEQTzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2014 15:55:35 -0400
In-Reply-To: <20140517.013655.349586284786993619.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 17, 2014 at 8:36 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Sat, 17 May 2014 13:26:16 +0800
>
> > 'struct irq_affinity_notify' and the related functions are only defined
> > when SMP enabled, so at present, mlx4 has to only run under SMP.
> >
> > The related error (allmodconfig under unicore32):
>
> Making the entire driver depend upon SMP is not the answer,


Indeed, we would do that just for the relevant portion,


>
> other Mellanox developers said that a proper fix is pending
> so please be patient.
