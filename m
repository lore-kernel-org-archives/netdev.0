From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs copy_to_user].
Date: Fri, 12 May 2006 11:54:07 +0400
Message-ID: <20060512075407.GB11880@2ka.mipt.ru>
References: <20060511.000721.60889163.davem@davemloft.net> <20060511083031.GA12712@2ka.mipt.ru> <20060511161815.GA623@2ka.mipt.ru> <20060511.115409.89709859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34984 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751067AbWELHzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 03:55:31 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060511.115409.89709859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 11, 2006 at 11:54:09AM -0700, David S. Miller (davem@davemloft.net) wrote:
> BTW you make another massively critical error in your analysis of TCP
> profiles.
> 
> You mention that "tcp_v4_rcv()" shows up in your profiles and not
> __inet_lookup().  This __inet_lookup() is inlined, and thus it's cost
> shows up as "tcp_v4_rcv()".  I find such oversight amazing for someone
> as careful about details as you are :-)

Ugh, my fault.
But tcp_v4_rcv() also does a lot of other things which more likely
pushes this function in profile statistics :)

> I would suggest to look at instruction level profile hits, it makes
> such mistakes in analysis almost impossible :-)

It is much more challenging than running oprofile, so it will be
postponed for a while :)

-- 
	Evgeniy Polyakov
