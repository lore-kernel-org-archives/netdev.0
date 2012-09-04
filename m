From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Wed, 5 Sep 2012 00:21:45 +0300
Message-ID: <20120904212145.GC3602@redhat.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
 <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
 <87boitz044.fsf@xmission.com>
 <20120805185031.GA18640@redhat.com>
 <CAJZOPZ+ZHBg=vswgmWWz2D0GyWhD-ghkuY9_7CQB47uDmyzhsA@mail.gmail.com>
 <20120903212230.GA6795@redhat.com>
 <CAJZOPZJdmDY8rqHJ+jeuG2rLMj9CnwnemkBG=nxD=z9JBFQCRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	Erez Shitrit <erezsh@mellanox.co.il>,
	Ali Ayoub <ali@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757741Ab2IDVUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 17:20:48 -0400
Content-Disposition: inline
In-Reply-To: <CAJZOPZJdmDY8rqHJ+jeuG2rLMj9CnwnemkBG=nxD=z9JBFQCRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 04, 2012 at 09:50:09PM +0300, Or Gerlitz wrote:
> > And just to stress the point, document the limitations as well.
> 
> sure, not that I see concrete limitations for the **user** at this point, but
> if there are such, will put them clearly written.

Hmm, I'm afraid you mistook a short list of some major
bugs that jumped out at me for an exhaustive list.
This was not intended as such.

Here's how to find some of the limitations in your design
1. look through list archives. Some where pointed out to you
2. list everything ethernet does that you dont, or do differently
3. list everything ipoib does that you don't or do differently
4. list any extra setup work required on behalf of the user
5. check various overheads, compare with native ipoib and alternatives
   such as routing
6. if you still have an empty list of limitations and disadvantages,
   look again :)

The point is to have documentation that is useful both
for reviewers - so they can know which bugs are known
and which need to be reported; and for users -
who should not be expected to be familiar with
internals of your implementation.

-- 
MST
