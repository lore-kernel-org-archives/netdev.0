From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Improve hash function used for full_name_hash()
Date: Mon, 04 Jan 2010 12:47:11 -0800 (PST)
Message-ID: <20100104.124711.50820580.davem@davemloft.net>
References: <1262635784.8178.253.camel@groeck-laptop>
	<20100104122912.5f9d1ebb@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guenter.roeck@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48344
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752751Ab0ADUrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 15:47:09 -0500
In-Reply-To: <20100104122912.5f9d1ebb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 4 Jan 2010 12:29:12 -0800

> On Mon, 04 Jan 2010 12:09:44 -0800
> Guenter Roeck <guenter.roeck@ericsson.com> wrote:
> 
>> For example, when hashing "eth0" .. "eth9999" with a hash table size of 256,
>> the resulting minimum hash bucket depth is 0, the maximum depth is 563,
>> and the standard deviation is ~136.
> 
> The problem was a missing call to hash_32() on the result, and is
> already fixed in current kernel.

Added linux-kernel CC: to followup...
