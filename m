From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Tue, 27 Jan 2015 16:28:43 +0100
Message-ID: <1422372523.13969.23.camel@stressinduktion.org>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
		 <20150122224033.6e2db5ce@urahara>
		 <1422015737.2824.8.camel@stressinduktion.org>
		 <20150127045653.GB13164@gospo.home.greyhouse.net>
	 <1422351861.13969.5.camel@stressinduktion.org> <54C7A6D6.8020805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:57016 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751888AbbA0P2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 10:28:46 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 9C12120B12
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 10:28:45 -0500 (EST)
In-Reply-To: <54C7A6D6.8020805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-27 at 07:55 -0700, David Ahern wrote:
> On 1/27/15 2:44 AM, Hannes Frederic Sowa wrote:
> >> You are probably correct that many will not switch, but this sysctl
> >> gives those who want to switch a nice option without having to carry
> >> extra kernel patches.  I like it.
> >
> > I don't see any problem with the patch in general but DAD should
> > definitely happen on reenabling interfaces. Current behavior does not
> > seem fine to me. It's ok if this patch doesn't change this behavior now
> > but a follow-up one will be needed then.
> >
> > David, will you look after the DAD logic and do you plan a follow-up
> > patch?
> 
> Yes, I do plan a follow-up patch for this change. Will work on that this 
> week.
> 
>  From the discussion a second patch is needed to make sure DAD is done 
> on a link up if there is an address configured.

Thank you!

Let's see if the DAD patch isn't complex, maybe it is a candidate for
stable?
