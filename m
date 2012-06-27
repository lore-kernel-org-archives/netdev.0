From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 7/7] netlink: Get rid of obsolete rtnetlink macros
Date: Wed, 27 Jun 2012 08:35:32 -0700
Message-ID: <20120627083532.38566c87@nehalam.linuxnetplumber.net>
References: <cover.1340788373.git.tgraf@suug.ch>
	<a10752bf3eb27e13e61b817664d58a69f9179fc9.1340788373.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51317 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564Ab2F0Pfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 11:35:44 -0400
In-Reply-To: <a10752bf3eb27e13e61b817664d58a69f9179fc9.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Jun 2012 11:36:16 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Removes all RTA_GET*() and RTA_PUT*() variations, as well as the
> the unused rtattr_strcmp(). Get rid of rtm_get_table() by moving
> it to its only user decnet.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---

Nack. The RTA_ macros are exported to user space through kernel
headers process. If you do this it will break iproute2 build.
