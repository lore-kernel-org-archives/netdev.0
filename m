From: Nicolas Bareil <nico@chdir.org>
Subject: Re: [BUG] before() integer overflow
Date: Tue, 05 Aug 2008 20:24:27 +0200
Message-ID: <87pronqq04.fsf@chdir.org>
References: <OFD6FD9FE8.66BA8559-ON8825749C.00619B98-8825749C.00621A40@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:52240 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676AbYHESxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 14:53:46 -0400
In-Reply-To: <OFD6FD9FE8.66BA8559-ON8825749C.00619B98-8825749C.00621A40@us.ibm.com>
	(David Stevens's message of "Tue, 5 Aug 2008 10:51:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens <dlstevens@us.ibm.com> writes:
>         In the sequence space, 0xffffffff is before 0 (by 1), so
> before() should return true. In your example, you don't have enough
> f's for it to be -1 as a signed number, so I'm assuming you mean
> 8 of them there. If you mean 6 f's, then the result is not -1, but the
> positive number 0xffffff, which returns false.

Yes I meant 8 f (I should change my too small fonts ;) )

Thanks to Ben for his explanation, I thought the PAWS was handled in a
specific way. Sorry!

-- 
Nicolas Bareil                                  http://chdir.org/~nico/
OpenPGP=0xAE4F7057 Fingerprint=34DB22091049FB2F33E6B71580F314DAAE4F7057
