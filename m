From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink: unify registration functions
Date: Mon, 18 Nov 2013 10:57:18 +0100
Message-ID: <1384768638.17916.2.camel@jlt4.sipsolutions.net>
References: <1384521548-13241-1-git-send-email-johannes@sipsolutions.net>
	 <20131115.205205.1547026485764326432.davem@davemloft.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7429@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:36416 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194Ab3KRJ51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 04:57:27 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7429@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-18 at 09:54 +0000, David Laight wrote:

> Or does ARRAY_SIZE(x) already contain a check that
> sizeof(x) % sizeof(*(x)) is zero?

#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]) +
__must_be_array(arr))

__must_be_array() only works for gcc apparently, but that should be good
enough?

johannes
