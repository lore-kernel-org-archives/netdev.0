From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/26] Reliable Datagram Sockets (RDS), take 2
Date: Tue, 24 Feb 2009 23:28:14 -0800 (PST)
Message-ID: <20090224.232814.227017310.davem@davemloft.net>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: andy.grover@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50464
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754500AbZBYH2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:28:33 -0500
In-Reply-To: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Grover <andy.grover@oracle.com>
Date: Tue, 24 Feb 2009 17:30:17 -0800

> This patchset against net-next adds support for RDS sockets. RDS is an
> Oracle-originated protocol used to send IPC datagrams (up to 1MB)
> reliably, and is used currently in Oracle RAC and Exadata products. 
> 
> I've addressed all the issues from comments on take 1. (thanks!) This patchset
> squashes the changes into the original changeset, but I've also included
> a tree where the un-squashed changes since last time may be reviewed:
> git://git.openfabrics.org/~agrover/ofed_1_4/linux-2.6.git
> rds-broken-out-fixes
> 
> Major changes since last time include moving to net/rds, and the
> additional inclusion of iwarp transport support.

This makes RDMA too much of a first-class citizen in the networking
stack.  That's a blocker for me.

Furthermore the port you've choosen for the protocol is arbitrary, not
properly allocated with the appropriate standards committee, and
therefore could conflict with something other people are using.

I'm rejecting these patches, sorry.
