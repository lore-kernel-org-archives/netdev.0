From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] SELinux: Only return netlink error when we know
 the return is fatal
Date: Tue, 23 Nov 2010 10:59:15 -0800 (PST)
Message-ID: <20101123.105915.59672943.davem@davemloft.net>
References: <20101123162802.3588.74894.stgit@paris.rdu.redhat.com>
	<1290529955.5359.20.camel@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	sds@tycho.nsa.gov
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41101
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755908Ab0KWS6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 13:58:50 -0500
In-Reply-To: <1290529955.5359.20.camel@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Tue, 23 Nov 2010 11:32:35 -0500

> On Tue, 2010-11-23 at 11:28 -0500, Eric Paris wrote:
>> Some of the SELinux netlink code returns a fatal error when the error might
>> actually be transient.  This patch just silently drops packets on
>> potentially transient errors but continues to return a permanant error
>> indicator when the denial was because of policy.
>> 
>> Based-on-comments-by: Paul Moore <paul.moore@hp.com>
>> Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> Thanks for fixing this up.
> 
> Reviewed-by: Paul Moore <paul.moore@hp.com>

Applied.
