From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/4] [RFC] Add c/r support for connected INET sockets
Date: Wed, 21 Oct 2009 11:05:05 -0700
Message-ID: <87ws2oei7i.fsf@caffeine.danplanet.com>
References: <1256072803-3518-1-git-send-email-danms@us.ibm.com>
	<1256072803-3518-3-git-send-email-danms@us.ibm.com>
	<20091021175624.GA20972@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, John Dykstra <jdykstra72@gmail.com>,
	netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:34950 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754642AbZJUSFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 14:05:03 -0400
In-Reply-To: <20091021175624.GA20972@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 21 Oct 2009 12\:56\:24 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> Sorry, I think we've discussed this before but can't recall - does
SH> setting sport here allow an unpriv user to bypass
SH> CAP_NET_BIND_SERVICE?

Yes, it does.  I was kinda considering that part of the input sanity
checking that I officially punted on.  However, as far as I know,
we'll just need to check that capability before we bind() in the
listen/closed case and hash in the connected case.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
