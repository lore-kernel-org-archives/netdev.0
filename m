From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: syncookies: do not use getnstimeofday()
Date: Thu, 20 Mar 2014 16:16:19 -0400 (EDT)
Message-ID: <20140320.161619.826791792330039198.davem@davemloft.net>
References: <1395288141.9114.82.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140320.153645.1726836204043973392.davem@davemloft.net>
	<1395346059.9114.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759068AbaCTUQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:16:22 -0400
In-Reply-To: <1395346059.9114.95.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Mar 2014 13:07:39 -0700

> On Thu, 2014-03-20 at 15:36 -0400, David Miller wrote:
> 
>> This applies cleanly to net-next, but with this Fixes: tag I sort of
>> suspect you are targetting this at net instead?
>> 
>> Please be explicit as to what the target tree is when submitting
>> patches in the future.
> 
> Well, I've always tagged net-next patches with net-next, and used no tag
> for fixes.
> 
> If you want me to add net tag, I am totally fine.
> 
> So yes, this was a fix for net tree, but there is no hurry if you
> applied to net-next its also fine.

The confusion came mostly because it applied perfectly to net-next, but
with fuzz to plain net. :)
