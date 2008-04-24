From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Thu, 24 Apr 2008 13:59:28 -0700
Message-ID: <OF3EEB81D7.922E9337-ON88257435.00729F2D-88257435.00734E23@us.ibm.com>
References: <20080425.054328.51438140.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:55716 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbYDXU7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 16:59:33 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3OKxWNq018769
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 16:59:32 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3OKxWgM211120
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 14:59:32 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3OKxVot002852
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 14:59:32 -0600
In-Reply-To: <20080425.054328.51438140.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A general comment that I have is that you're making changes
that affect the non-compat case. Which, of course, is why I prefer
the approach I took in the patch I sent. The non-compat code is
completely untouched, and only the translations needed for
compatibility are done. This reduces (really, nearly removes)
the possibility of breaking existing working code, while only
risking bugs in apps that currently don't work at all.

Aside from that, I think the approach is just simpler, easier to
understand and review, and a  smaller patch. I can't
tell trivially by looking at your patch if errno is set the same on
all non-compat cases as it was before your patch, for example.
It may be, but I know it is in my patch without having to test all
those cases, because those are unchanged by the compat
code I added.

                                        +-DLS

