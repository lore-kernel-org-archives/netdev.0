From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [patch 05/11] ehca: ret is unsigned, ibmebus_request_irq() negative return ignored in hca_create_eq()
Date: Wed, 14 May 2008 16:37:43 -0700
Message-ID: <ada4p90ihiw.fsf@cisco.com>
References: <200805142320.m4ENKCQl026623@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, 12o3l@tiscali.nl,
	fenkes@de.ibm.com, hnguyen@de.ibm.com, paulus@samba.org,
	stefan.roscher@de.ibm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:13947 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbYENXhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:37:45 -0400
In-Reply-To: <200805142320.m4ENKCQl026623@imap1.linux-foundation.org>
	(akpm@linux-foundation.org's message of "Wed, 14 May 2008 16:20:12
	-0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a drivers/infiniband patch, not a drivers/net patch.

I believe this is already fixed upstream by 7df109d9 ("IB/ehca: handle
negative return value from ibmebus_request_irq() properly").

 - R.
