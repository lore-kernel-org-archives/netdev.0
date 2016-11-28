From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
Date: Sun, 27 Nov 2016 22:07:28 -0700
Message-ID: <7e3623c4-a55e-5809-ca9a-2dbd59cda871@cumulusnetworks.com>
References: <1480296725-5563-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <caa11887-00b9-d2f1-7c0b-5b5096b42f56@cumulusnetworks.com>
 <001c01d2491f$fcd53250$f67f96f0$@cmss.chinamobile.com>
 <6d1a324e-e29e-e2dd-a6fc-1e9b4455cb3d@cumulusnetworks.com>
 <001d01d24922$9a16b1e0$ce4415a0$@cmss.chinamobile.com>
 <a01fcd54-c0ed-9d05-743a-27592d845c56@cumulusnetworks.com>
 <6859d40b-0049-513a-6dc4-162d383ef7b9@cumulusnetworks.com>
 <001e01d24932$f7c0dd10$e7429730$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33390 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbcK1FHb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 00:07:31 -0500
Received: by mail-pf0-f174.google.com with SMTP id d2so22572257pfd.0
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 21:07:30 -0800 (PST)
In-Reply-To: <001e01d24932$f7c0dd10$e7429730$@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/16 9:50 PM, уей╓╬ы wrote:
> No, when dump request must be processed by multiple 'recv/recvmsg' system
> calls, 
> idx stores which dev/neigh the previous call have processed, so that next
> call will scan 
> from the right place.  

I have tested multiple calls and I do not see redundant information or missing information. 

> 
> So no matter whether the dev/neigh is filtered, the idx should be increased
> anyway.

No, it does not. Again, idx is the index in the list of devices/ of interest. It is NOT a device index nor is it the absolute index in the list. It is a relative index. The filter is the same across recvmsg calls so the idx count is absolutely fine.

Produce a test case that fails.
