From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 05/12] net/mlx5e: Poll rx cq before tx cq to
 improve round-trip latency
Date: Tue, 23 Jun 2015 17:12:54 +0300
Message-ID: <55896966.80704@mellanox.com>
References: <1434554789-13758-6-git-send-email-ogerlitz@mellanox.com>
	<20150621.102144.267706734504980452.davem@davemloft.net>
	<CAEHy93LdUDFVoxWU_++t1D5tqBSEM1TY4ZguW7QszvEyPOvagg@mail.gmail.com>
 <20150622.063554.1081040359354241131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <amirv@mellanox.com>,
	<talal@mellanox.com>, <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>, <achiad.mellanox@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0074.outbound.protection.outlook.com ([157.56.112.74]:49328
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933868AbbFWOMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 10:12:45 -0400
In-Reply-To: <20150622.063554.1081040359354241131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/22/2015 4:35 PM, David Miller wrote:
> From: achiad shochat <achiad.mellanox@gmail.com>
> Date: Mon, 22 Jun 2015 00:35:37 +0300
>
>> Hello Dave,
>>
>> In mlx5 the RX processing is broken down into two stages:
>> 1) Hand to kernel SKBs of completed RX packets - @mlx5e_poll_rx_cq()
>> 2) Allocate and post to HW new RX buffers - @mlx5e_post_rx_wqes()
>>
>> Would handling of TX completions in between stages (1) and (2) be OK?
> I would do all of TX processing first and synchronously.  It's very
> cheap and makes lots of resources available for RX processing.

So we'll drop this patch.

Or.
