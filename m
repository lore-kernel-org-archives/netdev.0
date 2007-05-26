From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: b44: regression in 2.6.22
Date: Fri, 25 May 2007 20:51:09 -0700
Message-ID: <1180151469.3136.6.camel@dhcp-10-12-136-115.broadcom.com>
References: <20070525172431.60affaca@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>,
	"Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3330 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbXEZFNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2007 01:13:44 -0400
In-Reply-To: <20070525172431.60affaca@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-05-25 at 17:24 -0700, Stephen Hemminger wrote:
> Something is broken with the b44 driver in 2.6.22-rc1 or later. Now bisecting.
> The performance (with iperf) for receiving is normally 94Mbits or more.
> But something happened that dropped performance to less than 1Mbit,
> probably corrupted packets.
> 
> There is nothing obvious in the commit log for drivers/net/b44.c, so it
> probably is something more general.

netperf in 2.6.22-rc2 seems ok. I'll give iperf a try to see if I can
repro the problem.

Thanks,
Gary


