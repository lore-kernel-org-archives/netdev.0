From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] dev_change_name: ignore changes to same name
Date: Fri, 26 Oct 2007 10:51:13 -0700
Message-ID: <47222911.7040106@hp.com>
References: <20071024064445.52b1e84e@shemminger-laptop> <20071026.035352.114927735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:42221 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641AbXJZRvP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 13:51:15 -0400
In-Reply-To: <20071026.035352.114927735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 24 Oct 2007 06:44:45 -0700
> 
> 
>>Prevent error/backtrace from dev_rename() when changing
>>name of network device to the same name. This is a common
>>situation with udev and other scripts that bind addr to device.
>>
>>Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> 
> Fair enough, applied.

Very timely!  I'd just built/booted a 2.6.24-rc1 kernel yesterday and it spent 
quite a  long time with stack traces (I have 16 interfaces on the system and a 
9600 baud console...I can only imagine what it would have been like on a big 
system...).  With the patch applied to that tree, it is now down to only three 
or so stack traces related to renames that were not there on 2.6.23.mumble.  Not 
sure if that warrants an acked-by but feel free if it makes sense.  (I'm still 
really fuzzy on those, even after reading SubmittingPatches)

rick jones
