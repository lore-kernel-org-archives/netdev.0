From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
Date: Sun, 27 Nov 2016 19:39:18 -0700
Message-ID: <6d1a324e-e29e-e2dd-a6fc-1e9b4455cb3d@cumulusnetworks.com>
References: <1480296725-5563-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <caa11887-00b9-d2f1-7c0b-5b5096b42f56@cumulusnetworks.com>
 <001c01d2491f$fcd53250$f67f96f0$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36221 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753805AbcK1CjV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 21:39:21 -0500
Received: by mail-pg0-f46.google.com with SMTP id f188so51242037pgc.3
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 18:39:20 -0800 (PST)
In-Reply-To: <001c01d2491f$fcd53250$f67f96f0$@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/16 7:34 PM, уей╓╬ы wrote:
>> -----Original Message-----
>> From: David Ahern [mailto:dsa@cumulusnetworks.com]
>> Sent: Monday, November 28, 2016 10:10 AM
>> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>;
>> netdev@vger.kernel.org
>> Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
>>
>> On 11/27/16 6:32 PM, Zhang Shengju wrote:
>>> Loop index in neigh dump function is not updated correctly under some
>>> circumstances, this patch will fix it.
>>
>> What's an example?
> 
> If dev is filtered out, the original code goes to next loop without updating
> loop index 'idx'.

And you have a use case with missing or redundant data? Or is your comment based on a review of code only?


>> You are completely rewriting the dump loops.
> 
> I put 'idx++' into for loop,  so I replace 'goto' with 'continue'.  The
> other change is style related. 

A "fixes" should not include 'style related' changes.
