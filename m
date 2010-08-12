From: Brian Haley <brian.haley@hp.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Thu, 12 Aug 2010 17:10:08 -0400
Message-ID: <4C646330.6080303@hp.com>
References: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:32288 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382Ab0HLVKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 17:10:11 -0400
In-Reply-To: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steve,

On 07/28/2010 11:20 PM, Steve Chen wrote:
> Hello,
> 
> The TAHI correspondent node tests CN-6-4-1 (Processing in upper layer
> - Echo Checksum) failed for me in the 2.6.32 kernel.  It appears that
> the Linux kernel is replying the ICMP echo request in
> icmpv6_echo_reply without much checking.  Is this an intentional
> non-conformance to RFC3775 section 9.3.1?

Sorry for the late reply.  I've run these tests in the past against
SLES11 (2.6.27 ?) back in January 2009 and this one passed from looking
at my logs.  I don't have that system around anymore to check the config,
etc.  I didn't see any obvious commit that would have broken it from a
quick look, do you have a test setup to do some debugging?  It will
take a little time for me to re-configure mine to run this test.

-Brian
