From: Dave Chiluk <chiluk@canonical.com>
Subject: Re: Stable request for 5882a07c72093d
Date: Mon, 23 Jun 2014 12:35:43 -0500
Message-ID: <53A8656F.4070407@canonical.com>
References: <1403539016-15519-1-git-send-email-chiluk@canonical.com> <1403540316.27425.3.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: chiluk@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei-Chun Chao <weichunc@plumgrid.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38967 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754859AbaFWRfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 13:35:47 -0400
In-Reply-To: <1403540316.27425.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2014 11:18 AM, Eric Dumazet wrote:
> On Mon, 2014-06-23 at 10:56 -0500, Dave Chiluk wrote:
>> Commit 5882a07c72093dc3a18e2d2b129fb200686bb6ee remedies a BUG_ON in
>> skb_segment.  This is hit reliably in clouds that are using openvswitch for
>> network capabilities (which is the default network used by Openstack) on
>> machines that have gso offload capabilities.  
>>
>> This has already been reported multiple times to Canonical in numerous
>> openstack clouds.  The fix has been integrated and tested in those clouds, and
>> has been show to resolve their issues.
>>
>> Please include this patch for stable release.
>>
>> Thank you, 
>> Dave Chiluk
>>
>> The patch follows for convenience.
>> --
> 
> Both original commit and your request lack the bug origin.
> 
> I wish bug submissions are more explicit in this regard, using
> 
> Fixes: sha1-12digits ("title")
> 
> It would save a lot of time for stable teams, and ease future bug
> hunting as well.
> 
> 
According to the initial thread, Wei-Chun determined it originated with
19acc327258a.  It has existed since 3.10-rc1.

Fixes: 19acc327258a ("gso: Handle Trans-Ether-Bridging protocol in
skb_network_protocol()")
