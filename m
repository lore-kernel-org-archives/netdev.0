From: Brian Haley <brian.haley@hp.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Fri, 13 Aug 2010 13:55:27 -0400
Message-ID: <4C65870F.4080307@hp.com>
References: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>	<4C646330.6080303@hp.com>	<AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>	<4C64ACB2.3090600@hp.com> <AANLkTi=01koVqt6YR0LQi53Nx0E=7UT1TFVNL44TwAR4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:23653 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437Ab0HMRza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 13:55:30 -0400
In-Reply-To: <AANLkTi=01koVqt6YR0LQi53Nx0E=7UT1TFVNL44TwAR4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2010 01:34 PM, Steve Chen wrote:
>>>>> The TAHI correspondent node tests CN-6-4-1 (Processing in upper layer
>>>>> - Echo Checksum) failed for me in the 2.6.32 kernel.  It appears that
>>>>> the Linux kernel is replying the ICMP echo request in
>>>>> icmpv6_echo_reply without much checking.  Is this an intentional
>>>>> non-conformance to RFC3775 section 9.3.1?
[snip]

> It appears that skb->ip_summed is always 1 (CHECKSUM_UNNECESSARY).
> I'm using e1000e.  Looking at the driver, there is a checksum offload
> hardware.  I think the code is doing frame check on the entire
> Ethernet packet.  Since no error was found, it assume everything
> inside is correct.

# ethtool -K ethX rx off

Does that help?  Does using a different NIC help?

-Brian
