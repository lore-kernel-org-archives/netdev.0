From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH  v2 04/13] Connection Manager
Date: Mon, 04 Dec 2006 21:27:09 -0800
Message-ID: <aday7pmgbf6.fsf@cisco.com>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
	<20061202224958.27014.65970.stgit@dell3.ogc.int>
	<20061204110825.GA26251@2ka.mipt.ru> <ada8xhnk6kv.fsf@cisco.com>
	<20061205050725.GA26033@2ka.mipt.ru> <ada3b7uhqlk.fsf@cisco.com>
	<20061205051657.GB26845@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:24994 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967562AbWLEF1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 00:27:18 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061205051657.GB26845@2ka.mipt.ru> (Evgeniy Polyakov's message of "Tue, 5 Dec 2006 08:16:58 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > So will each new NIC implement some parts of TCP stack in theirs drivers?

I hope not.  The driver we merged (amso1100) did it completely in FW,
with a separate MAC and IP interface for the RDMA connections.  I
think we better understand the Chelsio driver pretty well and think it
over carefully before we merge it.

Thanks for pointing this stuff out.

 - R.
