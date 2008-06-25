From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: RFC:  Patch to add support for multiple multicast routing
 tables.
Date: Tue, 24 Jun 2008 22:28:07 -0700
Message-ID: <20080624222807.3a9918d1@speedy>
References: <4861966B.5090208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:43153 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbYFYF2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 01:28:22 -0400
In-Reply-To: <4861966B.5090208@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jun 2008 17:50:51 -0700
Ben Greear <greearb@candelatech.com> wrote:

> In order to run multiple Xorp instances and treat different groups of
> interfaces as being in their own virtual router, I had to update the
> ipv4/ipmr.c logic to support multiple routing tables.
> 
> I will be attempting to push the cooresponding xorp changes to it's
> maintainers if this is accepted into the kernel.  It should be fully
> backwards compatible with existing xorp and other multicast
> routing tools.  It does change the procfs output slightly, adding
> a TableId column.
> 
> The original patch was written by me, and then Patrick McHardy
> fixed up my cruft and made it much smaller and with better locking.
> I then fixed a few bugs I found while testing with my modified xorp.
> 
> The attached patch is against 2.6.25.4 + hacks.  It has a few rejects 
> against 2.6.26.rc7,
> but I will fix those sooner rather than later if the patch is otherwise 
> deemed
> worthy.
> 
> Please let me know if this stands a chance of inclusion.
> 
> Thanks,
> Ben

Ben private ioctl's make it hard to handle 32bit/64bit compatiablity,
and routing is better managed through rtnetlink. Doesn't XORP do
netlink?
