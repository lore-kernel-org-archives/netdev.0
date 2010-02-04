From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/86] dccp: fix bug in cache allocation
Date: Wed, 03 Feb 2010 19:01:54 -0800 (PST)
Message-ID: <20100203.190154.46617335.davem@davemloft.net>
References: <1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1265005087-5549-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<20100201115638.GB25094@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753314Ab0BDDBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:01:41 -0500
In-Reply-To: <20100201115638.GB25094@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 1 Feb 2010 06:56:38 -0500

> On Mon, Feb 01, 2010 at 07:18:06AM +0100, Gerrit Renker wrote:
>> This fixes a bug introduced in commit de4ef86cfce60d2250111f34f8a084e769f23b16
>> ("dccp: fix dccp rmmod when kernel configured to use slub", 17 Jan): the
>> vsnprintf used sizeof(slab_name_fmt), which became truncated to 4 bytes, since
>> slab_name_fmt is now a 4-byte pointer and no longer a 32-character array.
>> 
>> This lead to error messages such as
>>  FATAL: Error inserting dccp: No buffer space available
>> 
>>  >> kernel: [ 1456.341501] kmem_cache_create: duplicate cache cci
>> generated due to the truncation after the 3rrdc character.
>> 
>> Fixed for the moment by introducing a symbolic constant. Tested to fix the bug.
>> 
>> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> 
> These changes make sense, sorry for not seeing that earlier.  Thanks!
> 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
