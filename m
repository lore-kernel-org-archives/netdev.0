From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 5/6] tg3: Fix bug in nvram write
Date: Sat, 29 Apr 2006 19:00:38 -0700 (PDT)
Message-ID: <20060429.190038.80336531.davem@davemloft.net>
References: <1146267381.4780.18.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19909
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750872AbWD3CAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 22:00:21 -0400
To: mchan@broadcom.com
In-Reply-To: <1146267381.4780.18.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 28 Apr 2006 16:36:21 -0700

> Fix bug in nvram write function. If the starting nvram address offset
> happens to be the last dword of the page, the NVRAM_CMD_LAST bit will
> not get set in the existing code. This patch fixes the bug by changing
> the "else if" to "if" so that the last dword condition always gets
> checked.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Good catch, applied.

Thanks.
