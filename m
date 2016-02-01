From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC net-next 9/9] net/mlx5e: Flow steering support through switchdev
Date: Mon, 1 Feb 2016 23:45:07 +0200
Message-ID: <CAJ3xEMhvx+JR43VvQnBpeJcV8d-j5TN48nmkJyJ9OUEW=Z9k5w@mail.gmail.com>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
	<1454315685-32202-10-git-send-email-amir@vadai.me>
	<CALzJLG_8nB+CrHi1R3kWVK+Ap5d+V8ErN16VsV9ypFmnPw4CJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amir@vadai.me>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:32841 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbcBAVpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 16:45:08 -0500
Received: by mail-io0-f171.google.com with SMTP id f81so172795471iof.0
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 13:45:08 -0800 (PST)
In-Reply-To: <CALzJLG_8nB+CrHi1R3kWVK+Ap5d+V8ErN16VsV9ypFmnPw4CJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 1, 2016 at 8:52 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:

[...]

> in case it is, please consider using the vport_manager capability or
> any other device capability meant for this,
> to initialize and activate mlx5e_switchdev.
>
> After all such offload might not be supported in some devices. e.g VF.

This offloading should be working on VFs too, we're offloading into HW
12-tuple classification to flow-tags and drops.
