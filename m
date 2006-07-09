From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED]: act_api: Fix module leak while flushing actions
Date: Sun, 09 Jul 2006 11:38:58 -0700 (PDT)
Message-ID: <20060709.113858.01310628.davem@davemloft.net>
References: <20060709142043.GN14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24222
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161038AbWGISi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 14:38:27 -0400
To: tgraf@suug.ch
In-Reply-To: <20060709142043.GN14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sun, 9 Jul 2006 16:20:43 +0200

> Module reference needs to be given back if message header
> construction fails.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.

This reminds me of something, not only are non-networking developers
getting tripped up constantly about these magic code labels referenced
from the netlink macros, they are tripping us up as well.

I really think it's time, at a minimum, to explicitly mention the
labels as an argument to the macros, or something like that.

I'll try to cons something up when I get a chance.  The current
situation is too error prone.

