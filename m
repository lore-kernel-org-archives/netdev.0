From: Max Matveev <makc@redhat.com>
Subject: Re: [PATCH 1/2] Update description of net.sctp.sctp_rmem and
 net.sctp.sctp_wmem tunables
Date: Tue, 5 Jul 2011 12:00:19 +1000
Message-ID: <19986.28723.546267.454485@regina.usersys.redhat.com>
References: <20110704083605.AF9C28156C57@regina.usersys.redhat.com>
	<20110704145454.GA10310@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662Ab1GECA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 22:00:27 -0400
In-Reply-To: <20110704145454.GA10310@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Jul 2011 10:54:54 -0400, Neil Horman wrote:

 nhorman> On Mon, Jun 20, 2011 at 06:08:10PM +1000, Max Matveev wrote:

 >> sctp_rmem - vector of 3 INTEGERs: min, default, max
 >> -	See tcp_rmem for a description.
 >> +	Only the first value ("min") is used, "default" and "max" are
 >> +	ignored and may be removed in the future versions.
 >> +

 nhorman> Its accurate to say that only the first value is usd
 nhorman> currently, but because of the way this sysctl is contructed
 nhorman> (its used by the sysctl_rmem pointer in the sctp_prot
 nhorman> struct, which expects an array of three integers in the
 nhorman> commong __sk_mem_schedule function), we wont' be removing
 nhorman> the other two values.

Technically it can be just a single integer - UDP does use it 
that way but I'm not going to argue, v2 of the patch removed
that bit.

max
