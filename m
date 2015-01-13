From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 10:00:48 -0500
Message-ID: <20150113150048.GA28371@oracle.com>
References: <54B4A7E4.7030301@gmail.com>
 <20150112231021.316648e3@urahara>
 <1421145346.13626.12.camel@redhat.com>
 <54B50873.4090907@miraclelinux.com>
 <54B50C71.7090007@miraclelinux.com>
 <1421152613.13626.24.camel@redhat.com>
 <54B53187.7080306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@redhat.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20948 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378AbbAMPBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 10:01:03 -0500
Content-Disposition: inline
In-Reply-To: <54B53187.7080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/13/15 07:53), David Ahern wrote:
> 
> The current code seems inconsistent: I can put an IPv6 address on a
> link in the down state. On a link up the address is retained. Only
> on a subsequent link down is it removed. If DAD or anything else is
> the reason for the current logic then why allow an address to be
> assigned in the down state? Similarly that it currently seems to
> work ok then it suggests the right thing is done on a link up in
> which case a flush is not needed.
> 
> Bottom line is there a harm in removing the flush? If there is no
> harm will mainline kernel take a patch to do that or is your
> backward compatibility concern enough to block it?

Does some of this have to do with the manner in which this interacts
with SLAAC? I recall that there were two schools of thought for doing
DAD when SLAAC is present: one says it is sufficient to just do DAD
on the interface-id, the other requies DAD on the whole 128-bit IPv6
address. I'm not sure which choice linux makes.

--Sowmini
