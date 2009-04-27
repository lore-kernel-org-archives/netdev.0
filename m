From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] forcedeth: tx timeout fix
Date: Mon, 27 Apr 2009 11:59:45 -0700
Message-ID: <20090427115945.d736ac1f.akpm@linux-foundation.org>
References: <49F361E4.4050605@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, manfred@colorfullife.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37843 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754554AbZD0TCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 15:02:41 -0400
In-Reply-To: <49F361E4.4050605@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Apr 2009 15:17:56 -0400
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> This patch fixes the tx_timeout() to properly handle the clean up of the 
> tx ring. It also sets the tx put pointer back to the correct position to 
> be in sync with HW.

It's unclear (to me) what the real-world impact of this bugfix is. 
There isn't enough information here to decide whether the fix should be
backported to 2.6.29 (and earlier?).  What is the user-visible
behaviour change?  What hardware does it affect?  What is the risk that
the change will inadvertently break other setups?  etc.

Please always provide such information in the changelogs.

