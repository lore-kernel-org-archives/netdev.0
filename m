From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8152: correct error returns
Date: Tue, 05 Aug 2014 12:52:04 -0700 (PDT)
Message-ID: <20140805.125204.500612433909991155.davem@davemloft.net>
References: <1407049618.26893.8.camel@linux-fkkt.site>
	<20140804.151827.179999106523102125.davem@davemloft.net>
	<1407224584.12844.5.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbaHETwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 15:52:05 -0400
In-Reply-To: <1407224584.12844.5.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Tue, 05 Aug 2014 09:43:04 +0200

> On Mon, 2014-08-04 at 15:18 -0700, David Miller wrote:
>> But of course, that doesn't handle the non-autopm code paths into the
>> PM layer that can end up in this situation.
> Hm. Are they numerous? Which did you find?

I didn't find any specifically, I just know that there are other
callers of that inner-most helper function so those paths need
to be checked too.
