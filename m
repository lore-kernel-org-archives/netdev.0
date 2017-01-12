From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 12:25:33 -0800
Message-ID: <1484252733.13165.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484251157-245538-1-git-send-email-shannon.nelson@oracle.com>
         <1484252011.13165.0.camel@edumazet-glaptop3.roam.corp.google.com>
         <cd152a9f-4855-a552-2b45-bd619436a628@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@oracle.com>, netdev@vger.kernel.org,
        davem@davemloft.net, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Rob Gardner <rob.gardner@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34515 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdALUZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:25:40 -0500
In-Reply-To: <cd152a9f-4855-a552-2b45-bd619436a628@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-12 at 13:15 -0700, Rob Gardner wrote:

> 
> I suspect that someplace, somebody is casting val to an int * or 
> something like that.

Then that would be the bug. Can we root cause this please ?
