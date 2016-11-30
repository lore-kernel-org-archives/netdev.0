From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net-next] neigh: remove duplicate check for same neigh
Date: Tue, 29 Nov 2016 18:56:45 -0700
Message-ID: <5e12cb25-516a-8b52-2768-eb87bca1c6f8@cumulusnetworks.com>
References: <1480407771-12884-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <d641245a-8442-9238-a507-6f94184354a0@cumulusnetworks.com>
 <000201d24aa8$f63c6500$e2b52f00$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36486 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbcK3B4s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 20:56:48 -0500
Received: by mail-pg0-f50.google.com with SMTP id f188so75567456pgc.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 17:56:47 -0800 (PST)
In-Reply-To: <000201d24aa8$f63c6500$e2b52f00$@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/16 6:27 PM, уей╓╬ы wrote:
> This has less changes, but I preferred to add a new function to do the
> filter logic, this is the same as your code  @rtnl_dump_ifinfo().

I'd prefer it to stay in line as it is now. You can save the cycles of filtering on already viewed entries without an overhaul of this code.
