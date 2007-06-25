From: David Miller <davem@davemloft.net>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS
 autoconfiguration
Date: Sun, 24 Jun 2007 19:53:19 -0700 (PDT)
Message-ID: <20070624.195319.39483510.davem@davemloft.net>
References: <200706231625.44825@auguste.remlab.net>
	<c6d9bea0706230747y79d39a6eh3c55de3a29cfb4d1@mail.gmail.com>
	<1182737851.16455.3.camel@xo-13-A4-25.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cscott@laptop.org, rdenis@simphalempin.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39771
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751742AbXFYCxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 22:53:00 -0400
In-Reply-To: <1182737851.16455.3.camel@xo-13-A4-25.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw@redhat.com>
Date: Sun, 24 Jun 2007 22:17:31 -0400

> The glibc guys rejected things like periodically stat()-ing resolv.conf.

At least these days such a thing could be re-proposed using
something like inotify(), although it might be difficult
to get glibc to receive that even asynchronously and without
eating a file descriptor.

