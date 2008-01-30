From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] [1/2] Skip empty hash buckets faster in /proc/net/tcp
Date: Wed, 30 Jan 2008 09:03:16 -0800
Message-ID: <adasl0fb60b.fsf@cisco.com>
References: <20080130901.138686634@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: meissner@suse.de, netdev@vger.kernel.org, davem@davemloft.net
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:51695 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756766AbYA3RDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 12:03:19 -0500
In-Reply-To: <20080130901.138686634@suse.de> (Andi Kleen's message of "Wed, 30 Jan 2008 09:01:09 +0100 (CET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > On a 2GB Core2 system here I see a time cat /proc/net/tcp > /dev/null
 > constently dropping from 0.44s to 0.4-0.8s system time with this change.

Seems like there must be a typo in either the before or after times
you report here?
