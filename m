From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows with MD5SIG enabled (v2)
Date: Wed, 18 Jun 2008 12:39:03 -0700
Message-ID: <396556a20806181239q30024b8bv551f76a890befb0e@mail.gmail.com>
References: <20080617.170718.260234361.davem@davemloft.net>
	 <396556a20806171745k63bb3516s5971593ecf216bc4@mail.gmail.com>
	 <20080618023446.aba6516c.billfink@mindspring.com>
	 <20080618.015206.22767411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:22390 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbYFRTjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 15:39:05 -0400
Received: by rv-out-0506.google.com with SMTP id k40so4771483rvb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 12:39:03 -0700 (PDT)
In-Reply-To: <20080618.015206.22767411.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2008 at 1:52 AM, David Miller <davem@davemloft.net> wrote:
> It's pretty easy, depending upon the timestamp resolution, to
> end up with the original transmit and the retransmit having
> the same timetsamp value.  So this suggestion in the RFC is
> I think not a complete solution.

I happen to have just (unintentionally) simulated this, i.e. a
situation where MD5 signed packets with SACKs were dropped by the
receiving host. The transmitting host keeps sending packets with SACKs
and they keep getting dropped: the connection stalled.

AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
