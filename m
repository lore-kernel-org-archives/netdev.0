From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 00/11] net: L3 master device
Date: Tue, 29 Sep 2015 17:52:10 -0600
Message-ID: <560B242A.5070702@cumulusnetworks.com>
References: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
 <20150929.162306.94737407786085218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33937 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbbI2XwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:52:13 -0400
Received: by padhy16 with SMTP id hy16so19888301pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 16:52:13 -0700 (PDT)
In-Reply-To: <20150929.162306.94737407786085218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/29/15 5:23 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Mon, 28 Sep 2015 10:16:50 -0700
>
>> v2
>> - rebased to top of net-next
>>
>> - addressed Niks comments (checking master, removing extra lines, and
>>    flipping the order of patches 1 and 2)
>
> This still needs some work:
>
> ERROR: "l3mdev_master_ifindex_rcu" [net/ipv6/ipv6.ko] undefined!
> scripts/Makefile.modpost:90: recipe for target '__modpost' failed
> make[1]: *** [__modpost] Error 1
> Makefile:1095: recipe for target 'modules' failed
> make: *** [modules] Error 2
>

ugh. All of my builds have CONFIG_IPV6=y. Will kickout a v3 later.
