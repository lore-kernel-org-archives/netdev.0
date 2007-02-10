From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 0/5]: spidernet: misc fixes
Date: Fri, 9 Feb 2007 18:01:28 -0600
Message-ID: <20070210000128.GJ5616@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:34713 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423372AbXBJABb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 19:01:31 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1A01Usr012590
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:01:30 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1A01U47262904
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:01:30 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1A01T6b019291
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:01:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Jeff, 

A series of five patches against the spidernet ethernet device driver.

The first fixes a compile break in the current kernel.rg tree.
The second restructures the descriptor ring, per an old suggestion.
The third & fourth fix a race condition seen under heavy load.
The fifth is a trite janitorial patch.

Please apply.

--linas
