From: Theodore Tso <tytso@mit.edu>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Wed, 14 Jun 2006 06:36:05 -0400
Message-ID: <20060614103605.GA17831@thunk.org>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <200606131859.43695.chase.venters@clientec.com> <20060613183112.B8460@openss7.org> <200606131953.42002.chase.venters@clientec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bidulock@openss7.org, Daniel Phillips <phillips@google.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from thunk.org ([69.25.196.29]:48261 "EHLO thunker.thunk.org")
	by vger.kernel.org with ESMTP id S1750995AbWFNKgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 06:36:40 -0400
To: Chase Venters <chase.venters@clientec.com>
Content-Disposition: inline
In-Reply-To: <200606131953.42002.chase.venters@clientec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 13, 2006 at 07:53:19PM -0500, Chase Venters wrote:
> > It is the lack of an ABI that is most frustrating to these users.
> 
> And the presence of an ABI would be _very_ frustrating to core
> developers. Not only would these people suffer, everyone would --
> developer time would be wasted dealing with cruft, and forward
> progress would be slowed.

Note that just because an interface is EXPORT_SYMBOL doesn't mean that
the interface is guaranteed to be stable.  So folks who are aruging
that an interface shouldn't be usable by non-GPL applications because
we are therefore guaranteeing a stable API are making an unwarranted
assumption.

						- Ted
