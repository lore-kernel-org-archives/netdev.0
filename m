From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 10:13:52 -0500
Message-ID: <20150113151352.GB28371@oracle.com>
References: <54B4A7E4.7030301@gmail.com>
 <20150112231021.316648e3@urahara>
 <1421145346.13626.12.camel@redhat.com>
 <54B50873.4090907@miraclelinux.com>
 <54B50C71.7090007@miraclelinux.com>
 <1421152613.13626.24.camel@redhat.com>
 <54B53187.7080306@gmail.com>
 <20150113150048.GA28371@oracle.com>
 <1421161791.13626.33.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34269 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbAMPOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 10:14:00 -0500
Content-Disposition: inline
In-Reply-To: <1421161791.13626.33.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/13/15 16:09), Hannes Frederic Sowa wrote:
> 
> Yes, it does have something to do with it. But I didn't understand what
> you meant by doing DAD on the interface-id.

I have to dig up the RFCs for this, but I recall that, at one point,
the specs assert that it is sufficient to verify that the interface-id
(I think via DAD for the link-local address) is unique, and use
that to infer uniqueness of all the other non-link-local addresses
as well.

I think later specs may have changed that, asserting that the
correct, safe, proper thing to do is to separately DAD each address
by itself.

> If you look at the patches I just posted, only addresses which are in
> link-local and not in permanent state will be flushed.
> 
> I also need to do research on how to safely approach this, I don't know,
> yet.
> 
> Bye,
> Hannes
> 
> 
