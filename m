From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RDMA will be reverted
Date: Tue, 04 Jul 2006 13:34:30 -0700
Message-ID: <adar7119kix.fsf@cisco.com>
References: <ada3bdmfjug.fsf@cisco.com>
	<20060630.141658.34759102.davem@davemloft.net>
	<1151708503.11835.8.camel@trinity.ogc.int>
	<20060701.144506.74722126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@opengridcomputing.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:7316 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S932392AbWGDUec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 16:34:32 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060701.144506.74722126.davem@davemloft.net> (David Miller's message of "Sat, 01 Jul 2006 14:45:06 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Roland stated that it has never been the case that we have
 > rejected adding support for a certain class of devices on the
 > kinds of merits being discussed in this thread.  And I'm saying
 > that TOE is such a case where we have emphatically done so.

Well, in the past it's seemed more like patches have been rejected not
because of a blanket refusal to consider support for certain hardware,
but rather because of issues with the patches themselves.  eg last
year when Chelsio submitted some TOE hooks, you wrote the following
<http://marc.theaimsgroup.com/?l=linux-netdev&m=112382991506811&w=2>

  >> There is no way you're going to be allowed to call such deep TCP
  >> internals from your driver.

  >> This would mean that every time we wish to change the data structures
  >> and interfaces for TCP socket lookup, your drivers would need to
  >> change.

which looks like a very good reason to reject the changes.

 > So I am not saying iWARP or RDMA is equal to TOE, and if you had
 > actually read this thread you would have understood that.

There's definitely been quite a bit of conflation between the two in
this thread, even if you're not responsible...

 - R.
