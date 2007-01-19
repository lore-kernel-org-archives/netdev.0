From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/12] forcedeth: tx max work
Date: Thu, 18 Jan 2007 21:52:33 -0500
Message-ID: <45B03271.5080802@pobox.com>
References: <45A3DF43.8030301@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47572 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932863AbXASCwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 21:52:39 -0500
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <45A3DF43.8030301@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch adds a limit to how much tx work can be done in each 
> iteration of tx processing.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

What about the "tail end" of the work, when the limit is reached?

Remember that delaying the completion of TX's too long increases latency.

It seems to me that this patch needs a timer or somesuch, to guarantee 
that TX completions are not delayed too long in the worst case.

	Jeff



