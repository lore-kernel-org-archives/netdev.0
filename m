From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Thu, 30 Jul 2009 22:10:53 +0000
Message-ID: <1248991853.8639.8.camel@Maple>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	 <1248295301-30930-6-git-send-email-danms@us.ibm.com>
	 <4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
	 <4A6F6B19.9010508@librato.com>  <878wi6yxui.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oren Laadan <orenl@librato.com>, containers@lists.osdl.org,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:23969 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbZG3WK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 18:10:57 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1264866rvb.5
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 15:10:58 -0700 (PDT)
In-Reply-To: <878wi6yxui.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-30 at 08:49 -0700, Dan Smith wrote:
> In fact, in my testing, if you try
> to connect() C back to A, you get "Operation not permitted" because A
> is already connected elsewhere.

I suspect this is a testing error.  Connecting a datagram socket does
not change or query the state of the target--it is a purely local
operation.

  --  John

