From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Thu, 02 Jul 2009 16:23:09 -0700
Message-ID: <m1ws6qu0te.fsf@fess.ebiederm.org>
References: <200903011344.45814.denys@visp.net.lb>
	<200907030022.55186.denys@visp.net.lb>
	<m1y6r6wwxy.fsf@fess.ebiederm.org>
	<200907030203.08294.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60049 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbZGBXXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 19:23:09 -0400
In-Reply-To: <200907030203.08294.denys@visp.net.lb> (Denys Fedoryschenko's message of "Fri\, 3 Jul 2009 02\:03\:08 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


What IOS is irrelevant to this discussion.
Especially when I don't see the "ip proxy-arp" command.

Having two networks:
10.0.0.0/24 physical segment
10.0.1.0/24 physical segment

It is correct for proxy arp to answer to for 10.0.0.66
when it is plugged into the 10.0.1.0/24 network.

Because in that case 10.0.0.66 is on the wrong subnet, and your
network is misconfigured.

Eric
