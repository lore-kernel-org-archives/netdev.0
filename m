From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Fix memory hog of ip batched command.
Date: Fri, 13 Jul 2012 09:26:48 -0700
Message-ID: <20120713092648.443ab0d8@nehalam.linuxnetplumber.net>
References: <1342142466-28270-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpettit@nicira.com, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37577 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756668Ab2GMQ1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 12:27:06 -0400
In-Reply-To: <1342142466-28270-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jul 2012 18:21:06 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> ipaddr_list_or_flush() builds list of all device at start of
> every flush or list operation, but does not free memory at end.
> This can hog lot of memory for large batched command.
> Following patch fixes it.
> 
> Reported-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

The list of addresses (ainfo) also leaks here.
