From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] SELinux: indicate fatal error in compat netfilter
 code
Date: Tue, 23 Nov 2010 10:59:22 -0800 (PST)
Message-ID: <20101123.105922.115928591.davem@davemloft.net>
References: <20101123162802.3588.74894.stgit@paris.rdu.redhat.com>
	<20101123162808.3588.18495.stgit@paris.rdu.redhat.com>
	<1290529928.5359.19.camel@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	sds@tycho.nsa.gov
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41106
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755908Ab0KWS64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 13:58:56 -0500
In-Reply-To: <1290529928.5359.19.camel@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Tue, 23 Nov 2010 11:32:08 -0500

> On Tue, 2010-11-23 at 11:28 -0500, Eric Paris wrote:
>> The SELinux ip postroute code indicates when policy rejected a packet and
>> passes the error back up the stack.  The compat code does not.  This patch
>> sends the same kind of error back up the stack in the compat code.
>> 
>> Based-on-patch-by: Paul Moore <paul.moore@hp.com>
>> Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> Reviewed-by: Paul Moore <paul.moore@hp.com>

Applied.
