From: Ingo Molnar <mingo@elte.hu>
Subject: [build bug] nf_nat_proto_sctp.c:(.text+0x6d173): undefined
	reference to `crc32c_le'
Date: Mon, 21 Apr 2008 08:22:44 +0200
Message-ID: <20080421062244.GA862@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ian Schram <ischram@telenet.be>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Tomas Winkler <tomas.winkler@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:60928 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505AbYDUGXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 02:23:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> and after i restarted last night's QA run, within a few iterations a 
> fourth build failure popped up:

and here's a fifth build failure in the networking code, triggered in 
our testing:

  net/built-in.o: In function `sctp_manip_pkt':
  nf_nat_proto_sctp.c:(.text+0x6d173): undefined reference to `crc32c_le'
  nf_nat_proto_sctp.c:(.text+0x6d180): undefined reference to `crc32c_le'
  nf_nat_proto_sctp.c:(.text+0x6d196): undefined reference to `crc32c_le'
  nf_nat_proto_sctp.c:(.text+0x6d1c6): undefined reference to `crc32c_le'

  http://redhat.com/~mingo/misc/config-Mon_Apr_21_01_52_14_CEST_2008.bad

	Ingo
