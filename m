From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 0/2] bonding: add its own Kconfig
Date: Wed, 16 Jul 2014 09:20:32 +0200
Message-ID: <20140716072032.GA12030@mikrodark.usersys.redhat.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
 <20140715.181056.2116924949727575928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:36799 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759384AbaGPHXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 03:23:31 -0400
Received: by mail-we0-f179.google.com with SMTP id u57so449966wes.10
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 00:23:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140715.181056.2116924949727575928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 06:10:56PM -0700, David Miller wrote:
>From: Veaceslav Falico <vfalico@gmail.com>
>Date: Tue, 15 Jul 2014 12:15:39 +0200
>
>> Currently to change some built-in defaults it's necessary to change the
>> code, and to maintain these patches on each update.
>>
>> Create a bonding's Kconfig to make it possible to configure them at build
>> time.
>
>There is really no reason these values can't be set at run time, and that
>is my only, but firm, objection to this patch series.

Yeah, MIIMON default value doesn't really need to exist, vlan depth can be
configured dynamically ...

>
>For the per-slave things, make new netlink attributes that can be provided
>when the slave is added, using the existing default if not specified.
>
>This means the fixed sized arrays involved here need to become
>dynamically allocated.

... and arp ip targets can be also made into lists.

I'll try to change it and come up with split patchsets.

Thank you!
