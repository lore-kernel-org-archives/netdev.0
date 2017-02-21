From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net-next][PATCH] RDS: keep data type consistent in the user
 visible header
Date: Tue, 21 Feb 2017 14:58:49 +0000
Message-ID: <0437debe-fd44-20ab-c2d2-02c14255da9a@solarflare.com>
References: <1487387747-5324-1-git-send-email-santosh.shilimkar@oracle.com>
 <20170220.101951.663166903772216217.davem@davemloft.net>
 <20170220153722.GB16561@oracle.com>
 <20170220.103912.194197218422769191.davem@davemloft.net>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6CA26@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        'David Miller' <davem@davemloft.net>,
        "sowmini.varadhan@oracle.com" <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:44662 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752571AbdBUO7U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 09:59:20 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE6CA26@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/02/17 14:29, David Laight wrote:
>> The entire file should use the proper "__uX" kernel types
>> rather than the uint* ones.
> The uint* ones are part of the C standard :-)
>
> 	David
>
... which is exactly why we can't use them.

http://yarchive.net/comp/linux/kernel_headers.html#17

Visibility of <stdint.h> types is defined by a twisty maze of standards, all different (POSIX, SuS, BSD_SOURCE, XOPEN_SOURCE...).

__u8 and friends are in the reserved system namespace, so we can safely use them in user headers.

-Ed
