From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 13:31:06 -0700
Message-ID: <adar6kryd4l.fsf@cisco.com>
References: <200709211201.24475.vda.linux@googlemail.com>
	<200709211803.55554.vda.linux@googlemail.com>
	<20070921.104912.41646795.davem@davemloft.net>
	<200709211905.23946.vda.linux@googlemail.com>
	<p73ps0b93ph.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Vlasenko <vda.linux@googlemail.com>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2-in.cisco.com ([171.71.176.71]:12720 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbXIUUbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 16:31:09 -0400
In-Reply-To: <p73ps0b93ph.fsf@bingen.suse.de> (Andi Kleen's message of "21 Sep 2007 22:13:46 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Just change the makefiles to always install gzip'ed modules
 > modutils knows how to unzip them on the fly.

But that leaves the uncompressed firmware blobs in .data that ends up
in unswappable kernel memory.

 - R.
