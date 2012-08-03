From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: remove parentheses in return statement
Date: Fri, 03 Aug 2012 14:31:33 -0700 (PDT)
Message-ID: <20120803.143133.1203794725115288810.davem@davemloft.net>
References: <1343979790-17408-1-git-send-email-sakiwit@gmail.com>
	<20120803.015243.1041602621154758483.davem@davemloft.net>
	<20120803202350.GA7520@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769Ab2HCVbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 17:31:36 -0400
In-Reply-To: <20120803202350.GA7520@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Fri, 3 Aug 2012 14:23:50 -0600

> To illustrate, the patch merely changes
> 
> 	return (A);
> 
> to
> 
> 	return A;

Life is not black and white my friend, there are shades
of gray.  I feel bad for you if you read coding style rules
in a %100 literal sense with no room for interpretation.

People add extra parenthesis to add clarity, so you are
entirely misrepresenting these cases.

This was not a simple case of:

	return (A);

but more like something that looks as:

	return ((A & B) | (C ^ D));

and that is perfectly fine.
