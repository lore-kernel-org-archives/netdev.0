From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: RE: [PATCH 2/7 net-2.6.26] [TIPC]: Add argument validation for shutdown()
Date: Tue, 4 Mar 2008 13:58:05 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0252E545@ala-mail02.corp.ad.wrs.com>
References: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com><1204665619-6345-3-git-send-email-allan.stephens@windriver.com> <20080304.134354.42311642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56876 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053AbYCDV6Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:58:16 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080304.134354.42311642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arrgh!  You're right, Dave.  I was concentrating on fixing the problems
with my email client and let things get out of sync.  I'll fix 'em up
and resubmit.

-- Al 

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, March 04, 2008 4:44 PM
To: Stephens, Allan
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH 2/7 net-2.6.26] [TIPC]: Add argument validation for
shutdown()

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue,  4 Mar 2008 16:20:14 -0500

> This patch validates that the "how" argument to shutdown() is 
> SHUT_RDWR, since this is the only form that TIPC supports.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

You really didn't generate this patch against the current
net-2.6.26 tree:

davem@sunset:~/src/GIT/net-2.6.26$ pcheck diff
+ git apply --check --whitespace=error-all diff
error: patch failed: net/tipc/socket.c:1432
error: net/tipc/socket.c: patch does not apply

The line numbers are all off.  Likely you generated this against a
net-2.6.26 tree from before the semaphore-->mutex TIPC changeset went
in, throwing all the line numbers off.

I'm not looking at the rest of your patches, sorry.

