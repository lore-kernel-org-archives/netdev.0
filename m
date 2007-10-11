From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: bytes received from recvmsg doesn't match FIONREAD
Date: Thu, 11 Oct 2007 16:36:34 -0700
Message-ID: <OFAFD6A29A.64702BD9-ON88257371.0080B2DD-88257371.00819926@us.ibm.com>
References: <1192144096.4147.16.camel@balance>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: sdake@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:41811 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbXJKXgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 19:36:40 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9BNactf004040
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 19:36:38 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9BNac3r473584
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 17:36:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9BNabRc025427
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 17:36:38 -0600
In-Reply-To: <1192144096.4147.16.camel@balance>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Questions of this sort should normally be directed to linux-net mailing 
list.

>From the code you quoted, I see at least one case where it
will fail -- when the allocated buffer you pass to recvmsg is smaller than
"value" (ie. the datagram is too big for the read buffer).

If that's not the problem, I suggest you reproduce it with a small test
case and post real code and results when it happens.

                                                +-DLS 


