From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 18:34:02 +0100
Message-ID: <1421170442.23374.3.camel@stressinduktion.org>
References: <54B50C71.7090007@miraclelinux.com>
	 <1421152613.13626.24.camel@redhat.com> <54B53187.7080306@gmail.com>
	 <20150113.122542.815831933030545121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, hideaki.yoshifuji@miraclelinux.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:37845 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751190AbbAMReG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:34:06 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 828C120F03
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 12:34:05 -0500 (EST)
In-Reply-To: <20150113.122542.815831933030545121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-13 at 12:25 -0500, David Miller wrote:
> From: David Ahern <dsahern@gmail.com>
> Date: Tue, 13 Jan 2015 07:53:59 -0700
> 
> > Bottom line is there a harm in removing the flush? If there is no harm
> > will mainline kernel take a patch to do that or is your backward
> > compatibility concern enough to block it?
> 
> Backward compatibility trumps all other concerns here, and I say is
> enough to block changing the behavior.  One which we've had for more
> than a decade.

Totally agreed, a new sysctl will definitely be needed and the default
should be the old behavior. Otherwise we cannot do it.
