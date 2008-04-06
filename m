From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC 2/5] vringfd base/offset
Date: Sun, 6 Apr 2008 12:54:32 +1000
Message-ID: <200804061254.33153.rusty@rustcorp.com.au>
References: <200804052202.09157.rusty@rustcorp.com.au> <200804052204.28518.rusty@rustcorp.com.au> <47F77431.3030608@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org
To: Avi Kivity <avi@qumranet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48785 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673AbYDFCy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 22:54:56 -0400
In-Reply-To: <47F77431.3030608@qumranet.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 05 April 2008 22:44:33 Avi Kivity wrote:
> Rusty Russell wrote:
> > It turns out the lguest (and possibly kvm) want the addresses in the
> > ring buffer to only cover a certain part of memory, and be offset.
> >
> >  					<mailto:rusty@rustcorp.com.au>
> > +0xAE	00-01	linux/vring.h
>
> Another virtualization subsystem already uses this range.

Nasty.  Not listed in the ioctl list, and didn't find it with grep 8(.  I 
don't think I ever used 0xAD which was assigned to me, so I can change to 
that.

Thanks,
Rusty.
