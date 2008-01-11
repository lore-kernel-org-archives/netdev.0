From: Vince Fuller <vaf@cisco.com>
Subject: Re: [PATCH 001/001] ipv4: enable use of 240/4 address space
Date: Fri, 11 Jan 2008 09:29:15 -0800
Message-ID: <20080111172915.GA6199@cisco.com>
References: <20080108011057.GA21168@cisco.com> <p73bq7smx1t.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vince Fuller <vaf@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:12011 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760805AbYAKRbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 12:31:46 -0500
Content-Disposition: inline
In-Reply-To: <p73bq7smx1t.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 12:17:02PM +0100, Andi Kleen wrote:
> Vince Fuller <vaf@cisco.com> writes:
> 
> > from Vince Fuller <vaf@vaf.net>
> >
> > This set of diffs modify the 2.6.20 kernel to enable use of the 240/4
> > (aka "class-E") address space as consistent with the Internet Draft
> > draft-fuller-240space-00.txt.
> 
> Wouldn't it be wise to at least wait for it becoming an RFC first? 

There is reasonable consensus on making use of 240/4; some applications,
such as ISAKMP and automatic ipv6-to-IPv4 tunneling, still need to determine
if they should treat the space as "public" or "private" but that shouldn't
affect whether kernel support is added.

Solaris recently added support for 240/4 and OSX already has it. I thought
the Linux kernel developers might appreciate having patches to do likewise.

I leave it up to you, the developers, to decide if you want to use these
patches.

	--Vince
