From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove COMPAT_NET_DEV_OPS
Date: Sun, 24 May 2009 14:32:07 -0700 (PDT)
Message-ID: <20090524.143207.59391234.davem@davemloft.net>
References: <1243088259-16482-1-git-send-email-a.beregalov@gmail.com>
	<20090523074143.445ef830@nehalam>
	<20090523165531.GA14081@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, a.beregalov@gmail.com,
	netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53252
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752052AbZEXVcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 17:32:08 -0400
In-Reply-To: <20090523165531.GA14081@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 23 May 2009 12:55:31 -0400

> On Sat, May 23, 2009 at 07:41:43AM -0700, Stephen Hemminger wrote:
>> On Sat, 23 May 2009 18:17:39 +0400
>> Alexander Beregalov <a.beregalov@gmail.com> wrote:
>> 
>> > All drivers are already converted to new net_device_ops API
>> > and nobody uses old API anymore.
>> > 
>> > Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
>> 
>> This go through the feature-removal-schedule process, to
>> allow other drivers that live outside the tree some notice for change.
> 
> I don't think so.  We do tons of API changes and don't do such a process
> around it.  Removal of the old pointers gives a clear compilation
> breakage so it's not even dangerous.

I completely agree and plan to get rid of this compat ops stuff
for 2.6.31
