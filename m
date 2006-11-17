From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH  11/13] Core Resource Allocation
Date: Fri, 17 Nov 2006 12:37:03 -0800
Message-ID: <ada4psxn72o.fsf@cisco.com>
References: <20061116035826.22635.61230.stgit@dell3.ogc.int>
	<20061116035923.22635.5397.stgit@dell3.ogc.int>
	<adaslgim2tt.fsf@cisco.com> <1163784311.8457.44.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:27561 "EHLO
	sj-iport-5.cisco.com") by vger.kernel.org with ESMTP
	id S1755882AbWKQUhF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 15:37:05 -0500
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1163784311.8457.44.camel@stevo-desktop> (Steve Wise's message of "Fri, 17 Nov 2006 11:25:11 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > I think we can use random32() or get_random_bytes().  I need to
 > re-review how this algorithm works.  Its randomizing the stag IDs so
 > they are not predictable.

I assume based on the algorithm you have now that they don't need to
be cryptographically unpredictable.  So random32() would probably be
the best thing to do (get_random_bytes() should be used sparingly,
since it depletes the kernel entropy pool).

 - R.
