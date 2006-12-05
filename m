From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH  v2 04/13] Connection Manager
Date: Mon, 04 Dec 2006 21:13:59 -0800
Message-ID: <ada3b7uhqlk.fsf@cisco.com>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
	<20061202224958.27014.65970.stgit@dell3.ogc.int>
	<20061204110825.GA26251@2ka.mipt.ru> <ada8xhnk6kv.fsf@cisco.com>
	<20061205050725.GA26033@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:20171 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968363AbWLEFOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 00:14:04 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061205050725.GA26033@2ka.mipt.ru> (Evgeniy Polyakov's message of "Tue, 5 Dec 2006 08:07:25 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > It is for iwarp/rdma from description.

Yes, iWARP on top of 10G ethernet.

 > If it is 10ge, then why does it parse incomping packet headers and
 > implements initial tcp state machine?

To establish connections to run RDMA over, I guess.  iWARP is RDMA
over TCP.

 - R.
