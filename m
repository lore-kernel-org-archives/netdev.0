From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/16] Spidernet RX Locking
Date: Thu, 07 Dec 2006 05:09:20 -0500
Message-ID: <4577E850.6040500@pobox.com>
References: <20061206223223.GH17931@austin.ibm.com> <20061206233134.GC4649@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36212 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031931AbWLGKJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 05:09:27 -0500
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061206233134.GC4649@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> The RX packet handling can be called from several
> places, yet does not protect the rx ring structure.
> This patch places the ring buffer pointers under a lock.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Cc: James K Lewis <jklewis@us.ibm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

This is a HUGELY invasive patch.  A sledgehammer.

What /specifically/ are these "several places", and what other 
non-sledgehammer approaches were discarded before arriving at this one?

	Jeff



