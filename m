From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: ping6: why TTL instead of Hop Limit?
Date: Sun, 8 Jan 2012 00:33:04 +0100
Message-ID: <20120107233304.GA618@hell>
References: <CAAfuxnJX0ULFvUbrNag2TE3brTZiBv6x9X9_bKnAuD9Q_Oe1Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dan Luedtke <maildanrl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:32944 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751823Ab2AGXdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 18:33:10 -0500
Content-Disposition: inline
In-Reply-To: <CAAfuxnJX0ULFvUbrNag2TE3brTZiBv6x9X9_bKnAuD9Q_Oe1Jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Dan Luedtke | 2012-01-07 19:07:03 [+0100]:

>I was just wondering why there is a TTL-field in ping6, although the
>corresponding field in the IPv6 header is called "Hop Limit". [1]
>
>Example:
>> ping6 -c 1 www.linux-ipv6.org
>> 64 bytes from 2001:200:dff:fff1:216:3eff:fea4:f9e9: icmp_seq=1 ttl=48 time=309 ms
>
>What I expected:
>> 64 bytes from 2001:200:dff:fff1:216:3eff:fea4:f9e9: icmp_seq=1 hl=48 time=309 ms
>
>Anyone an idea?
>Should I write a patch or is there a special reason for this?

Sorry, to late! You will break scripts/programms that parse ping6.

Hagen
