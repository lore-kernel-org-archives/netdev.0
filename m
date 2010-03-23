From: David Miller <davem@davemloft.net>
Subject: Re: [RFC Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Mon, 22 Mar 2010 21:58:22 -0700 (PDT)
Message-ID: <20100322.215822.123414773.davem@davemloft.net>
References: <4BA823D7.4010106@redhat.com>
	<20100322.204939.146100390.davem@davemloft.net>
	<4BA847EB.9040808@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	jmoyer@redhat.com
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BA847EB.9040808@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Tue, 23 Mar 2010 12:47:39 +0800

> Yeah, for bonding case, probably. But for bridge case, I think
> we still need to check all, right?

Why?  Who cares?

If it goes out one port and reaches it's destination
the objective has been achieved.

Sending it out N more times achieves nothing.
