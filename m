From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/macvtap: fix reference counting
Date: Mon, 15 Feb 2010 21:53:41 -0800 (PST)
Message-ID: <20100215.215341.66627877.davem@davemloft.net>
References: <201002111645.02770.arnd@arndb.de>
	<201002111655.40349.arnd@arndb.de>
	<1265922577.28768.6.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, kaber@trash.net, eswierk@aristanetworks.com,
	netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41363
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752831Ab0BPFx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:53:26 -0500
In-Reply-To: <1265922577.28768.6.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 11 Feb 2010 13:09:37 -0800

> On Thu, 2010-02-11 at 16:55 +0100, Arnd Bergmann wrote:
>> The RCU usage in the original code was broken because
>> there are cases where we possibly sleep with rcu_read_lock
>> held. As a fix, change the macvtap_file_get_queue to
>> get a reference on the socket and the netdev instead of
>> taking the full rcu_read_lock.
>> 
>> Also, change macvtap_file_get_queue failure case to
>> not require a subsequent macvtap_file_put_queue, as
>> pointed out by Ed Swierk.
> 
> Looks good.
> 
> Acked-by: Sridhar Samudrala <sri@us.ibm.com>

Applied.
