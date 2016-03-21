From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Mon, 21 Mar 2016 15:04:27 -0400 (EDT)
Message-ID: <20160321.150427.643988574824179278.davem@davemloft.net>
References: <20160315075223.GB2263@nanopsycho.orion>
	<56E7C30C.7020009@cumulusnetworks.com>
	<20160315082417.GC2263@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org, jhs@mojatatu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757815AbcCUTTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 15:19:47 -0400
In-Reply-To: <20160315082417.GC2263@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 15 Mar 2016 09:24:17 +0100

> Tue, Mar 15, 2016 at 09:08:44AM CET, roopa@cumulusnetworks.com wrote:
>>Apart from the usability concern i have described earlier, this just seems an overkill ...having to redefine every attribute.
> 
> I don't hear the usability concern. User knows how to compose/parse
> attrs, no problem there.

But if we compartmentalize the most common use case into the header
itself, then the user doesn't even have to deal with attributes at
all.

This is what we've (intelligently, not stupidly) done in the past.

When we build a new facility, we put the most fundamental elements
into the message header structure.

There is nothing wrong with this at all.

If we run out of bits for the filter mask, we can (intelligently, not
stupidly) add a new attribute for that.

This is nothing in the realm of "good netlink design" that says that
we should use attributes for everything.  In fact I would say that
netlink attribute diahrrea should be avoided.

Therefore I am more than happy to see the filter mask stay in the
message header, and I will apply changes from Roopa which implement
it this way.

I've read your arguments, I understand your position and your
reasoning, but I simply disagree with you.

Thanks.
