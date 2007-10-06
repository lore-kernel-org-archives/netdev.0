From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/5] forcedeth: several proposed updates for testing
Date: Sat, 06 Oct 2007 11:24:20 -0400
Message-ID: <4707A8A4.8030005@garzik.org>
References: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59190 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759446AbXJFPY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 11:24:29 -0400
In-Reply-To: <20071006151250.GA17020@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> The goals of these changes are:
> * move the driver towards a more sane, simple, easy to verify locking
>   setup -- irq handler would often acquire/release the lock twice
>   for each interrupt -- and hopefully

  s/and hopefully//   (it became the next bullet point)

