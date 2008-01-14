From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [patch 5/7] netxen: fix race in interrupt / napi
Date: Mon, 14 Jan 2008 10:00:21 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801140959480.2721@dut46.unminc.com>
References: <20071226182352.704678179@netxen.com> <20071226182927.778015972@netxen.com>
 <4789414B.40800@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:34492 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751343AbYANR7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 12:59:35 -0500
In-Reply-To: <4789414B.40800@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I will respin the failed patches.

Thanks,
-Dhananjay

On Sat, 12 Jan 2008, Jeff Garzik wrote:

> patch conflicted with
> 
> commit 1706287f6eb58726a9a0e5cbbde87f49757615e3
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Jan 7 20:51:29 2008 -0800
> 
>     [NETXEN]: Fix ->poll() done logic.
> 
>     If work_done >= budget we should always elide the NAPI
>     completion.
> 
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
