From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] iproute2: Fix memory hog of ip batched command.
Date: Fri, 22 Jun 2012 09:26:31 -0700
Message-ID: <20120622092631.2753176a@nehalam.linuxnetplumber.net>
References: <1337726249-9958-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpettit@nicira.com, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36523 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762308Ab2FVQ0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2012 12:26:35 -0400
In-Reply-To: <1337726249-9958-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 May 2012 15:37:29 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> ipaddr_list_or_flush() builds list of all device at start of
> every flush or list operation, but does not free memory at end.
> This can hog lot of memory for large batched command.
> Following patch fixes it.
> 
> Reported-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Patch does not apply to current version.
Most likely Eric's recent changes to ipaddress conflict with this.
