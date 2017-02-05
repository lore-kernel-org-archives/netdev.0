From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Improve error handling during
 initialization
Date: Sat, 04 Feb 2017 19:47:14 -0500 (EST)
Message-ID: <20170204.194714.2295825542000326986.davem@davemloft.net>
References: <1485964222-1501-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        boris.ostrovsky@oracle.com, jgross@suse.com,
        linux-kernel@vger.kernel.org, wei.liu2@citrix.com
To: ross.lagerwall@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485964222-1501-1-git-send-email-ross.lagerwall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ross Lagerwall <ross.lagerwall@citrix.com>
Date: Wed, 1 Feb 2017 15:50:22 +0000

> * Delay timer creation so that if initializing a queue fails, the timer
> has not been setup yet.

setup_timer() doesn't do anything that must be "undone" if an error
occurs and we have to cleanup.

It just assigns some values to some timer struct fields, that's it.

Therefore this change is extraneous and unnecessary.
