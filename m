From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 9/24] make atomic_read() behave consistently on ia64
Date: Fri, 10 Aug 2007 14:19:29 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A0224C777@scsmsx411.amr.corp.intel.com>
References: <20070809135107.GA15985@shell.boston.redhat.com> <617E1C2C70743745A92448908E030B2A02213B3C@scsmsx411.amr.corp.intel.com> <46BCC1AF.5050204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <linux-kernel@vger.kernel.org>, <linux-arch@vger.kernel.org>,
	<torvalds@linux-foundation.org>, <netdev@vger.kernel.org>,
	<akpm@linux-foundation.org>, <ak@suse.de>,
	<heiko.carstens@de.ibm.com>, <davem@davemloft.net>,
	<schwidefsky@de.ibm.com>, <wensong@linux-vs.org>,
	<horms@verge.net.au>, <wjiang@resilience.com>,
	<cfriesen@nortel.com>, <zlynx@acm.org>, <rpjday@mindspring.com>,
	<jesper.juhl@gmail.com>
To: "Chris Snook" <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39805 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764929AbXHJVTb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:19:31 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46BCC1AF.5050204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> That's distressing.  I'm about to resubmit with a volatile cast in 
> atomic_set as well, since people expect that behavior and I've been 
> shown a legitimate case where it could matter.  Does the assembly look 
> right with that cast in atomic_set() as well?

No.  With the casts to volatile in atomic_set and atomic64_set I
still see places where ld8 is changed to ld4 + sign-extend.

-Tony
