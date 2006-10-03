From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 0/4]: Spidernet transmit patches
Date: Tue, 3 Oct 2006 15:52:40 -0500
Message-ID: <20061003205240.GE4381@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:47849 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030385AbWJCUwn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 16:52:43 -0400
To: akpm@osdl.org, jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The following set of four patches provide some more spidernet fixes.
Most important are a pair of patches to stop the transmit queue when it
is full, and to actually turn off transmit interrupts during NAPI(!)

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>


