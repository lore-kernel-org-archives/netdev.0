From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC 2/5] vringfd base/offset
Date: Sun, 6 Apr 2008 13:23:53 +1000
Message-ID: <200804061323.53566.rusty@rustcorp.com.au>
References: <200804052202.09157.rusty@rustcorp.com.au> <200804052204.28518.rusty__10896.9346424148$1207397431$gmane$org@rustcorp.com.au> <47F7B483.8090101@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50062 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553AbYDFDYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 23:24:15 -0400
In-Reply-To: <47F7B483.8090101@codemonkey.ws>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 06 April 2008 03:18:59 Anthony Liguori wrote:
> Rusty Russell wrote:
> > -	if (unlikely(get_user(head, &vr->ring.avail->ring[head]) != 0))
> > +
> > +	if (unlikely(get_user(head, &vr->ring.avail->ring[vr->last_avail
> > +							  % vr->ring.num])))
>
> Why not & with vr->mask for the sake of consistency with the rest of the
> code.

Thanks, fixed.

Rusty.
