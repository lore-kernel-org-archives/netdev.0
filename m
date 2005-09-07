From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 1/1] ipw2100: remove by-hand function entry/exit
 debugging
Date: Tue, 06 Sep 2005 19:41:11 -0700 (PDT)
Message-ID: <20050906.194111.130652562.davem@davemloft.net>
References: <200509062056.j86KuHcL031448@shell0.pdx.osdl.net>
	<431E4799.7000502@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, pavel@ucw.cz, ipw2100-admin@linux.intel.com,
	pavel@suse.cz, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750801AbVIGClb@vger.kernel.org>
To: jgarzik@pobox.com
In-Reply-To: <431E4799.7000502@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 06 Sep 2005 21:51:21 -0400

> NAK.  Rationale: maintainer's choice.  Pavel doesn't get to choose
> the debugger of choice for the driver maintainer.

If it makes the driver unreadable and thus harder to maintain,
I think such changes should seriously be considered.

Most of the DEBUG_INFO macro usage is fine, but those "enter"
and "exit" ones are just pure noise and should be removed.
