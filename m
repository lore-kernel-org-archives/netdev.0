From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC net-next 3/3] mpls: new ipmpls device for encapsulating IP packets as mpls
Date: Tue, 02 Jun 2015 18:23:50 -0500
Message-ID: <87vbf5g0e1.fsf@x220.int.ebiederm.org>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
	<1433177175-16775-4-git-send-email-rshearma@brocade.com>
	<87a8wivue4.fsf@x220.int.ebiederm.org>
	<20150602213738.GA5842@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46000 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbbFBX2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 19:28:53 -0400
In-Reply-To: <20150602213738.GA5842@pox.localdomain> (Thomas Graf's message of
	"Tue, 2 Jun 2015 23:37:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> writes:

> On 06/02/15 at 01:26pm, Eric W. Biederman wrote:
>> What we really want here is xfrm-lite.  By lite I mean the tunnel
>> selection criteria is simple enough that it fits into the normal
>> routing table instead of having to do weird flow based magic that
>> is rarely needed.
>> 
>> I believe what we want are the xfrm stacking of dst entries.
>
> I assume you are referring to reusing the selector and stacked
> dst. I considered that for the transmit side.
>
> Can you elaborate on this some more? How would this look like
> for the specific case of VXLAN? Any thoughts on the receive
> side? You also mention that you dislike the net_device approach.
> What do you suggest instead? The encapsulation is often postponed
> to after the packet is fully constructed. Where should it get
> hooked into?

Thomas I may have misunderstood what you are trying to do.

Is what you were aiming for roughly the existing RTA_FLOW so you can
transmit packets out one network device and have enough information to
know which of a set of tunnels of a given type you want the packets go
into?

Eric
