From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] [PATCH 0/26] Reliable Datagram Sockets (RDS), take 2
Date: Fri, 27 Feb 2009 18:08:34 +0100
Message-ID: <87myc73izx.fsf@basil.nowhere.org>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54711 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbZB0RK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 12:10:26 -0500
In-Reply-To: <1235525443-9007-1-git-send-email-andy.grover@oracle.com> (Andy Grover's message of "Tue, 24 Feb 2009 17:30:17 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Grover <andy.grover@oracle.com> writes:

> This patchset against net-next adds support for RDS sockets. RDS is an
> Oracle-originated protocol used to send IPC datagrams (up to 1MB)
> reliably, and is used currently in Oracle RAC and Exadata products. 

Perhaps I missed it earlier, but what is the rationale for putting 
this as a socket type into the kernel? I assume they also work
directly as implemented in user space using raw sockets or similar, 
don't they?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
