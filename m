From: David Miller <davem@davemloft.net>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 14:43:43 -0700 (PDT)
Message-ID: <20070824.144343.95051903.davem@davemloft.net>
References: <200708241559.17055.ossthema@de.ibm.com>
	<20070824164541.GG4282@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, netdev@vger.kernel.org, tklein@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, raisch@de.ibm.com, meder@de.ibm.com,
	stefan.roscher@de.ibm.com
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758017AbXHXVnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 17:43:46 -0400
In-Reply-To: <20070824164541.GG4282@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linas@austin.ibm.com (Linas Vepstas)
Date: Fri, 24 Aug 2007 11:45:41 -0500

> In the end, I just let it be, and let the system work as a
> busy-beaver, with the high interrupt rate. Is this a wise thing to
> do?

The tradeoff is always going to be latency vs. throughput.

A sane default should defer enough to catch multiple packets coming in
at something close to line rate, but not so much that latency unduly
suffers.
