From: Thomas Martitz <kugel@rockbox.org>
Subject: Re: [PATCH RFC 0/3] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 22 Sep 2015 11:14:48 +0200
Message-ID: <56011C08.4070109@rockbox.org>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mailbox.org ([80.241.60.212]:50284 "EHLO mx1.mailbox.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757028AbbIVJXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:23:08 -0400
In-Reply-To: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 21.09.2015 um 00:29 schrieb Tom Herbert:
> Kernel Connection Multiplexor (KCM) is a facility that provides a
> message based interface over TCP for generic application protocols.
> The motivation for this is based on the observation that although
> TCP is byte stream transport protocol with no concept of message
> boundaries, a common use case is to implement a framed application
> layer protocol running over TCP. To date, most TCP stacks offer
> byte stream API for applications, which places the burden of message
> delineation, message I/O operation atomicity, and load balancing
> in the application. With KCM an application can efficiently send
> and receive application protocol messages over TCP using a
> datagram interface.
>


Hello Tom,

on a general note I'm wondering what this offers over the existing SCTP 
support. SCTP offers reliable message exchange and multihoming already.

On a specific note, I'm wondering if the dup(2) familiy of system calls 
isn't a lot more suitable/natural instead of overloading accept.

Best regards.
