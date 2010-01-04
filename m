From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] [PATCH] Improve hash function used for full_name_hash()
Date: Mon, 4 Jan 2010 12:29:12 -0800
Message-ID: <20100104122912.5f9d1ebb@nehalam>
References: <1262635784.8178.253.camel@groeck-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: guenter.roeck@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49306 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146Ab0ADU3T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 15:29:19 -0500
In-Reply-To: <1262635784.8178.253.camel@groeck-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 Jan 2010 12:09:44 -0800
Guenter Roeck <guenter.roeck@ericsson.com> wrote:

> For example, when hashing "eth0" .. "eth9999" with a hash table size of 256,
> the resulting minimum hash bucket depth is 0, the maximum depth is 563,
> and the standard deviation is ~136.

The problem was a missing call to hash_32() on the result, and is
already fixed in current kernel.

-- 
