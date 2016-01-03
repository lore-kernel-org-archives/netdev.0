From: Felix Janda <felix.janda@posteo.de>
Subject: Re: [PATCH iproute2 1/2] Avoid in6_addr redefinition
Date: Sun, 3 Jan 2016 21:10:28 +0100
Message-ID: <20160103201028.GA4210@nyan>
Reply-To: 20151119143250.44a24eb4@xeon-e3
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:58584 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752406AbcACUMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jan 2016 15:12:39 -0500
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id 366F620460
	for <netdev@vger.kernel.org>; Sun,  3 Jan 2016 21:12:36 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-11-19 22:32:50 GMT Stephen Hemminger <stephen@networkplumber.org> wrote:
> This header file comes from iptables. Please fix there, otherwise
> on next time someone does merge from there it will break.

It is already fixed in iptables:

https://git.netfilter.org/iptables/commit/include/libiptc/ipt_kernel_headers.h?id=0bb1859e2d6dd79a0a59c3ee65f6a78cba118b86

Please sync the header with iptables.

Felix
