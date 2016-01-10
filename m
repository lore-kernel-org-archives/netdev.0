From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH linux-firmware] qed: Add firmware 8.7.3.0.
Date: Sun, 10 Jan 2016 14:30:00 -0500
Message-ID: <20160110193000.GA32062@merlin.infradead.org>
References: <1450429796-17998-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Sudarsana Reddy Kalluru <Sudarsana.Kalluru@qlogic.com>,
	linux-firmware@kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:36561 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757185AbcAJTyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 14:54:43 -0500
Content-Disposition: inline
In-Reply-To: <1450429796-17998-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 11:09:56AM +0200, Yuval Mintz wrote:
> From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@qlogic.com>
> 
> This patch pushes the next firmware for the QED module.
> This fixes numerous bugs, most notably:
>   - FLR flow isn't properly working.
>   - Chip might become unrespronsive after closing a vport.
>   - Chip gets stuck when transmitting packet with length > mtu.
> 
> It would also allow us to push future features such as:
>   - Vlan filter offload.
>   - Encapsulation offload.
>   - Single Root IOV support.
>   - Timesync.
>   - Non-L2 protocols.
> 
> >From L2 perspecitve, it's also note-worthy to state that it: 
>   - Changes fastpath HSI - fastpath will be moved to into using
>     Jumbo-over-BD.
>   - Improves throughput on single connection traffic.
> 
> Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

applied, sorry for the delay over the holidays.

regards, --kyle
