From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] cxgb4: exclude registers with read side
 effects from register dumps
Date: Sun, 11 Jul 2010 17:03:00 -0700 (PDT)
Message-ID: <20100711.170300.241920025.davem@davemloft.net>
References: <1278885679-3738-5-git-send-email-dm@chelsio.com>
	<1278885679-3738-6-git-send-email-dm@chelsio.com>
	<1278886626.6139.87.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39295
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753765Ab0GLACq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 20:02:46 -0400
In-Reply-To: <1278886626.6139.87.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 11 Jul 2010 23:17:06 +0100

> On Sun, 2010-07-11 at 15:01 -0700, Dimitris Michailidis wrote:
>> A few registers have side effects on reads, eg FIFO pointers that
>> auto advance or mailboxes which change ownership when read.  They are
>> unsafe to read so exclude them from ethtool register dumps.
> [...]
> 
> If you change the set of registers in the dump, you need to increment
> the version number.

Agreed.
