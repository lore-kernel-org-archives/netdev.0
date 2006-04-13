From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 02:00:10 -0700
Message-ID: <20060413020010.2ab16d7b.zaitcev@redhat.com>
References: <20060411085805.949313000@sipsolutions.net>
	<20060411085841.252064000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:28050 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751205AbWDMJAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 05:00:32 -0400
To: johannes@sipsolutions.net
In-Reply-To: <20060411085841.252064000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Apr 2006 10:58:06 +0200, johannes@sipsolutions.net wrote:

> Below patch was developed after discussion with Daniel Drake who
> mentioned to me that wireless tools expect an EAGAIN return from getscan
> so that they can wait for the scan to finish before printing out the
> results.

This sounds completely wrong. Do you guys remember the Subject: string
of this discussion by any chance?

It's very likely that tools do indeed loop when they see EAGAIN, but
this is a workaround, not the main mode of operation. It seems obvious
to me that the get method should wait until the scan results are
available. Perhaps the discussion had a specific scenario where
EAGAIN would make sense, but I cannot imagine what it might be.

-- Pete
