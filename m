From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 09:13:38 -0700
Message-ID: <452E69B2.4030306@hp.com>
References: <000101c6edd5$a880d430$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:31397 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S932273AbWJLQNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 12:13:39 -0400
To: Martin Schiller <mschiller@tdt.de>
In-Reply-To: <000101c6edd5$a880d430$1a04010a@V505CP>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Schiller wrote:
> Hi!
> 
> I'm searching for a solution to suppress / delay the SYN-ACK packet of a
> listening server (-application) until he has decided (e.g. analysed the
> requesting ip-address or checked if the corresponding other end of a
> connection is available) if he wants to accept the connect request of the
> client. If not, it should be possible to reject the connect request.

How often do you expect the incomming call to be rejected?  I suspect that would 
have a significant effect on whether the whole thing is worthwhile.

rick jones
