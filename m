From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: tcp: check skb is non-NULL for exact match on
 lookups
Date: Wed, 2 Nov 2016 15:05:21 -0600
Message-ID: <b311f957-fbfe-0153-d4c0-6de44466d2e3@cumulusnetworks.com>
References: <1478113705-16174-1-git-send-email-dsa@cumulusnetworks.com>
 <CAAeHK+yJ04mjcTkAdiuiWwOB-eG9UhQYZ0iDV5-xH6thmzza6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34569 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752710AbcKBVFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 17:05:23 -0400
Received: by mail-pf0-f174.google.com with SMTP id n85so18003565pfi.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 14:05:23 -0700 (PDT)
In-Reply-To: <CAAeHK+yJ04mjcTkAdiuiWwOB-eG9UhQYZ0iDV5-xH6thmzza6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/16 2:13 PM, Andrey Konovalov wrote:
> I can confirm that this fixes the null-ptr-deref I've been getting.
> 

Thanks, Andrey.
