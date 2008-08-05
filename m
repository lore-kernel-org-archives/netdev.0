From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [BUG] before() integer overflow
Date: Tue, 5 Aug 2008 10:51:32 -0700
Message-ID: <OFD6FD9FE8.66BA8559-ON8825749C.00619B98-8825749C.00621A40@us.ibm.com>
References: <87y73bqt0p.fsf@chdir.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Nicolas Bareil <nico@chdir.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:33905 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585AbYHERvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 13:51:53 -0400
In-Reply-To: <87y73bqt0p.fsf@chdir.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 08/05/2008 10:19:18 AM:

> 
> If seq1 = 0xffffff and seq2 = 0 (so seq1 > seq2), the difference is
> equal to 0xffffff, or -1 as a 32 bits signed number.

        In the sequence space, 0xffffffff is before 0 (by 1), so
before() should return true. In your example, you don't have enough
f's for it to be -1 as a signed number, so I'm assuming you mean
8 of them there. If you mean 6 f's, then the result is not -1, but the
positive number 0xffffff, which returns false.

                                                                +-DLS


