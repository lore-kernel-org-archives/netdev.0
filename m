From: Ricardo =?utf-8?b?VHViw61v?= <rtpardavila@gmail.com>
Subject: Re: Single socket with =?utf-8?b?VFhfUklORw==?= and =?utf-8?b?UlhfUklORw==?=
Date: Wed, 22 May 2013 19:36:34 +0000 (UTC)
Message-ID: <loom.20130522T212418-499@post.gmane.org>
References: <loom.20130515T144941-798@post.gmane.org> <20130515224452.7CAA6224C4@mail.nwl.cc> <loom.20130516T111446-437@post.gmane.org> <20130516104541.GB18282@orbit.nwl.cc> <loom.20130516T125157-378@post.gmane.org> <519A8D87.6080409@fnac.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:50188 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756362Ab3EVTgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 15:36:50 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UfEq9-0005l6-1C
	for netdev@vger.kernel.org; Wed, 22 May 2013 21:36:49 +0200
Received: from static-65-129-225-77.ipcom.comunitel.net ([static-65-129-225-77.ipcom.comunitel.net])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 21:36:49 +0200
Received: from rtpardavila by static-65-129-225-77.ipcom.comunitel.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 21:36:49 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Chavent <paul.chavent <at> fnac.net> writes:

> 
> Hi.
> 
> As stated before, you should call mmap only once.
> 
> Paul.
> 


Hi Paul,

I think that you must check the return value of the call that you make to
"setsockopt()", especially for the second call. The first one returns 0,
this is, the "setsockopt()" call was executed correctly. However, the second
one returns -16 ("EBUSY" value), this is, the call to "setsockopt()" was not
executed correctly.

So, could you modify your calls to "setsockopt()" and check whether the
return value is 0 (correct execution) or -16 (EBUSY, incorrect execution)?

Best, Cardo.
