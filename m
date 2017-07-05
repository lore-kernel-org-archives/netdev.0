From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] nfp: port enumeration change and FW ABI
 adjustment
Date: Wed, 05 Jul 2017 09:13:37 +0100 (WEST)
Message-ID: <20170705.091337.1800210019553158571.davem@davemloft.net>
References: <20170704092721.780-1-jakub.kicinski@netronome.com>
        <20170704.032949.30168457068908035.davem@davemloft.net>
        <20170704135207.51adade5@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36760 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751925AbdGEINn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 04:13:43 -0400
In-Reply-To: <20170704135207.51adade5@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 4 Jul 2017 13:52:07 -0700

> On Tue, 04 Jul 2017 03:29:49 -0700 (PDT), David Miller wrote:
>> From: Jakub Kicinski <jakub.kicinski@netronome.com>
>> Date: Tue,  4 Jul 2017 02:27:18 -0700
>> 
>> > This set changes the way ports are numbered internally to avoid MAC address
>> > changes and invalid link information when breakout is configured.  Second
>> > patch gets rid of old way of looking up MAC addresses in device information
>> > which caused all this confusion.
>> > 
>> > Patch 3 is a small adjustment to the new FW ABI version we introduced in
>> > this release cycle.
>> > 
>> > 
>> > To clarify these are intended for 4.13, naturally.  
>> 
>> net-next is closed, and it looks like these are not really bug fixes
>> but a behavior adjustment and therefore more like a new feature.
> 
> Ah, silly me, I had these ready on Friday but didn't want to participate
> in the just-before-the-merge-window rush :(

I've applied this series, thanks for explaining the situation more
clearly.
