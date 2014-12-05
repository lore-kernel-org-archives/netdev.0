From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next] tipc: fix missing spinlock init and nullptr oops
Date: Fri, 5 Dec 2014 13:39:53 +0100
Message-ID: <20141205123953.GA29024@haze>
References: <1417622320-19730-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <ying.xue@windriver.com>,
	<richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:46013 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbaLEMkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 07:40:04 -0500
Content-Disposition: inline
In-Reply-To: <1417622320-19730-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 03, 2014 at 04:58:40PM +0100, erik.hugne@ericsson.com wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> commit 908344cdda80 ("tipc: fix bug in multicast congestion
> handling") introduced two bugs with the bclink wakeup
> function. This commit fixes the missing spinlock init for the
> waiting_sks list. We also eliminate the race condition
> between the waiting_sks length check/dequeue operations in
> tipc_bclink_wakeup_users by simply removing the redundant
> length check.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Acked-by: Tero Aho <Tero.Aho@coriant.com>

Richard found another issue during regression testing closely related
to this, I have dropped it from patchwork and he will send in
v2.

//E
