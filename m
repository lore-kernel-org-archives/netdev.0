From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v1 net] net/mlx4: Avoid wrong virtual mappings
Date: Tue, 3 May 2016 21:15:19 +0300
Message-ID: <CAJ3xEMjO+0hrJyZ3bJGhGe9Yz2ckxky2C-OzE6oQMXFeW2xyGQ@mail.gmail.com>
References: <1461740820-15386-1-git-send-email-hagaya@mellanox.com>
	<CAJ3xEMjomTc5JNNEknk-JMBUtvAcb5xY8La4zT4mKG2Ad=V85Q@mail.gmail.com>
	<20160503.120032.1579415495628422336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Haggai Abramovsky <hagaya@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Sinan Kaya <okaya@codeaurora.org>,
	Timur Tabi <timur@codeaurora.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:35145 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964836AbcECSPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 14:15:20 -0400
Received: by mail-ob0-f172.google.com with SMTP id n10so9154384obb.2
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 11:15:20 -0700 (PDT)
In-Reply-To: <20160503.120032.1579415495628422336.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 3, 2016, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <gerlitz.or@gmail.com>

>> The patch changes the driver to do single allocation for potentially
>> very large HW WQE descriptor buffers such as those used by the RDMA
>> (mlx5_ib) driver.

> I know exactly what this patch does and how, but thanks for trying to
> teach me what it does anyways.

Dave,

This was more of a thinking out loud, not trying to teach you anything.

As I said, we're aiming for net-next, and as such the re-spin to
address your comment on bool vs int will be targeted there.

Or.
