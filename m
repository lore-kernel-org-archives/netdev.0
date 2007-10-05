From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Fri, 05 Oct 2007 16:10:59 -0700
Message-ID: <adave9lkvi4.fsf@cisco.com>
References: <adahclymos8.fsf@cisco.com>
	<000401c7f632$c993e8e0$65cc180a@amr.corp.intel.com>
	<adatzpyl1mm.fsf@cisco.com>
	<000001c7f6f7$074584e0$9c98070a@amr.corp.intel.com>
	<adaprzxgyoi.fsf@cisco.com>
	<000601c80525$0b661f30$ff0da8c0@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <general@lists.openfabrics.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Sean Hefty" <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:40169 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757721AbXJEXLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 19:11:13 -0400
In-Reply-To: <000601c80525$0b661f30$ff0da8c0@amr.corp.intel.com> (Sean Hefty's message of "Tue, 2 Oct 2007 11:50:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > I tested this by simulating a slow passive side responder, and it worked as
 > expected for those tests.  Using an MRA does add another MAD to the CM exchange,
 > which is why it is sent only after seeing a duplicate request.  Alternatively,
 > we can take the OFED module parameter patch.

What the heck, I added this for 2.6.24.  If it doesn't work out we can
back it out.

 - R.
