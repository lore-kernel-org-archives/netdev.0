From: David Miller <davem@davemloft.net>
Subject: Re: bug: micrel phy init (2.6.34-rc7)
Date: Mon, 10 May 2010 22:55:48 -0700 (PDT)
Message-ID: <20100510.225548.121246084.davem@davemloft.net>
References: <4BE88BED.4030400@oracle.com>
	<4BE88F22.3060408@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david.choi@micrel.com
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45846
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755290Ab0EKFzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 01:55:41 -0400
In-Reply-To: <4BE88F22.3060408@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 10 May 2010 15:56:34 -0700

> On 05/10/10 15:42, Randy Dunlap wrote:
>> Loading the micrel phy driver BUGs (no device present):
>> 
>> [  623.821462] BUG: unable to handle kernel NULL pointer dereference at (null)
>> [  623.822164] IP: [<ffffffff8123c9f0>] strcmp+0x6/0x44
>> [  623.822164] PGD 7d4bd067 PUD 7d6bb067 PMD 0 
>> [  623.822164] Oops: 0000 [#1] SMP
>> 
>> 
>> Full kernel log and config are attached.
>> 
>> Not a regression -- this is a new driver.
> 
> OK, I see that this was reported & fixed on May-06.  :)

:-)
