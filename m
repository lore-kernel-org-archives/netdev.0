From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: filter out messages not intended for this host
Date: Mon, 08 Mar 2010 12:20:30 -0800 (PST)
Message-ID: <20100308.122030.112176481.davem@davemloft.net>
References: <20100308194149.GD23634@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54867
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755656Ab0CHUUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:20:13 -0500
In-Reply-To: <20100308194149.GD23634@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 8 Mar 2010 14:41:49 -0500

> Port commit 20deb48d16fdd07ce2fdc8d03ea317362217e085
> from git://tipc.cslab.ericsson.net/pub/git/people/allan/tipc.git
> 
> Part of the larger effort I'm trying to help with getting all the downstreamed
> code from windriver forward ported to the upstream tree
> 
> Origional commit message
> Restore check to filter out inadverdently received messages
> This patch reimplements a check that allows TIPC to discard messages
> that are not intended for it.  This check was present in TIPC 1.5/1.6,
> but was removed by accident during the development of TIPC 1.7; it has
> now been updated to account for new features present in TIPC 1.7 and
> reinserted into TIPC.  The main benefit of this check is to filter
> out messages arriving from orphaned link endpoints, which can arise
> when a node exits the network and then re-enters it with a different
> TIPC network address (i.e. <Z.C.N> value).
> 
> tested with the tipc sanity test suite.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Origionally-authored-by: Allan Stephens <allan.stephens@windriver.com>

Adds trailing whitespace, please fix:

davem@sunset:~/src/GIT/net-2.6$ pcheck diff
+ git apply --check --whitespace=error-all diff
diff:11: trailing whitespace.
		if (unlikely(!msg_isdata(msg) && 
fatal: 1 line adds whitespace errors.

