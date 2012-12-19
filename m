From: Cong Wang <amwang@redhat.com>
Subject: RE: TCP delayed ACK heuristic
Date: Wed, 19 Dec 2012 15:00:36 +0800
Message-ID: <1355900436.6665.16.camel@cr0>
References: <270756364.27707018.1355842632348.JavaMail.root@redhat.com>
	 <2088500005.27728019.1355843484620.JavaMail.root@redhat.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>, Thomas Graf <tgraf@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747Ab2LSHBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 02:01:01 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 16:39 +0000, David Laight wrote:
> There are problems with only implementing the acks
> specified by RFC1122. 

Yeah, the problem is if we can violate this RFC for getting better
performance. Or it is just a no-no?

Although RFC 2525 mentions this as "Stretch ACK Violation", I am still
not sure if that means we can violate RFC1122 legally.

Thanks.
