From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: add schedule check to napi_enable call in refill_work
Date: Thu, 10 Feb 2011 12:01:19 +1030
Message-ID: <201102101201.19656.rusty@rustcorp.com.au>
References: <132885.30568.qm@web110313.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ken Stailey <kstailey@yahoo.com>, netdev@vger.kernel.org,
	"Bruce Rogers" <brogers@novell.com>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42548 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501Ab1BJBbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Feb 2011 20:31:22 -0500
In-Reply-To: <132885.30568.qm@web110313.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Feb 2011 06:59:25 am Ken Stailey wrote:
> Justification:
> 
> Impact: Under heavy network I/O load virtio-net driver crashes making VM guest unusable.

Hmm, this went badly wrong.  I acked this patch, and it was mailed to
netdev six months ago.

Bruce's patch used spaces instead of tabs, but that should not have caused
it to be dropped.  I've taken that and ported it forwards, will repost now.

Thanks for picking this up off the floor!
Rusty.
