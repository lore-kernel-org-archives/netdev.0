From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][PKTGEN] Fix double unlock of xfrm_state->lock
Date: Mon, 19 Nov 2007 22:51:53 -0800 (PST)
Message-ID: <20071119.225153.33244677.davem@davemloft.net>
References: <47415B94.1010002@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756540AbXKTGvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:51:53 -0500
In-Reply-To: <47415B94.1010002@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 19 Nov 2007 12:47:00 +0300

> The pktgen_output_ipsec() function can unlock this lock twice
> due to merged error and plain paths. Remove one of the calls
> to spin_unlock.
> 
> Other possible solution would be to place "return 0" right 
> after the first unlock, but at this place the err is known 
> to be 0, so these solutions are the same except for this one
> makes the code shorter.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
