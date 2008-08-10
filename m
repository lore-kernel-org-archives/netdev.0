From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Sat, 09 Aug 2008 22:46:37 -0700 (PDT)
Message-ID: <20080809.224637.69833549.davem@davemloft.net>
References: <489C8BEB.8060001@opengridcomputing.com>
	<489CC58D.4010606@pobox.com>
	<adazlnlzc60.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, swise@opengridcomputing.com, divy@chelsio.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750893AbYHJFqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 01:46:36 -0400
In-Reply-To: <adazlnlzc60.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Sat, 09 Aug 2008 22:12:07 -0700

> What I'm sure Chelsio and probably other iSCSI offload vendors
> would like is a way to make iSCSI (and other) offloads not steal magic
> ports but actually hook into the normal infrastructure so that the
> offloaded connections show up in netstat, etc.

Why show these special connections if the user cannot interact with or
shape the stream at all like normal ones?

This whole "make it look normal" argument is entirely bogus because
none of the standard Linux networking facilities can be applied to
these things.

And I even wonder, these days, if you probably get %90 or more of the
gain these "optimized" iSCSI connections obtain from things like LRO.
And since LRO can be done entirely in software (although stateless
HW assistence helps), it is even a NIC agnostic performance improvement.
