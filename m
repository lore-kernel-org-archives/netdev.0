From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Packet Corruption Support
Date: Wed, 16 Aug 2006 15:59:58 -0700
Message-ID: <20060816155958.2598bdff@localhost.localdomain>
References: <44E3A132.7090302@aston.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44437 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932313AbWHPXAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 19:00:07 -0400
To: Ritesh Taank <taankr@aston.ac.uk>
In-Reply-To: <44E3A132.7090302@aston.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Aug 2006 23:50:26 +0100
Ritesh Taank <taankr@aston.ac.uk> wrote:

> Hi there,
> 
> I am currently using netem that has been packaged with my linux kernel 
> 2.6.17 (as part of the Knoppix 5.0.1 Boot CD), and the 'corrupt' 
> parameter is not being recognised as a valid argument.
> 
> Having read many posts online, it appears that the Packet Corruption 
> feature should be supported from kernel versions 2.6.16 onwards.
> 
> So I was wondering why my version does not support the corrupt feature?
> 
> Are there any kernel versions out there that do support it?
> 
> I was wondering if there was a way to patch my existing kernel do enable 
> the corruption feature?
> 
> Any help/guidance is much appreciate.
> 
> Thanks in advance too.
> 
> Ritesh

It was introduced with this change set.

Author: Stephen Hemminger <shemminger@osdl.org>  2005-12-21 19:03:44
Committer: David S. Miller <davem@sunset.davemloft.net>  2006-01-03 13:11:05
Parent: aa8751667dcd757dd9a711b51140adf181501c44 ([PKT_SCHED]: sch_netem: correctly order packets to be sent simultaneously)
Child:  6d037a26f08711a222ed0d3d12b09e93eed7d3e8 ([PKT_SCHED]: Qdisc drop operation is optional)

    [PKT_SCHED] netem: packet corruption option
    
    Here is a new feature for netem in 2.6.16. It adds the ability to
    randomly corrupt packets with netem. A version was done by
    Hagen Paul Pfeifer, but I redid it to handle the cases of backwards
    compatibility with netlink interface and presence of hardware checksum
    offload. It is useful for testing hardware offload in devices.
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>


More likely the version if iproute2 utilities included with Knoppix is not
up to date and doesn't understand the command line option.
