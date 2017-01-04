From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] uapi: use wildcards to list files
Date: Wed, 4 Jan 2017 10:03:50 +0100
Message-ID: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
References: <20161203.192346.1198940437155108508.davem@davemloft.net>
 <1483454144-10519-1-git-send-email-nicolas.dichtel@6wind.com>
 <2108827.WpE3IvfEdH@wuerfel>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
        dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
        linux-media@vger.kernel.org, linux-mmc@vger.kernel.org,
        netfilter-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org, linux-spi@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-rdma@vger.kernel.org,
        fcoe-devel@open-fcoe.org, alsa-devel@alsa-project.org,
        linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        davem@davemloft.net, airlied@linux.ie,
        David Howells <dhowells@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36852 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966223AbdADJDa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 04:03:30 -0500
Received: by mail-wm0-f47.google.com with SMTP id c85so217644346wmi.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 01:03:30 -0800 (PST)
In-Reply-To: <2108827.WpE3IvfEdH@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/01/2017 à 22:37, Arnd Bergmann a écrit :
> On Tuesday, January 3, 2017 3:35:44 PM CET Nicolas Dichtel wrote:
>> Regularly, when a new header is created in include/uapi/, the developer
>> forgets to add it in the corresponding Kbuild file. This error is usually
>> detected after the release is out.
>>
>> In fact, all headers under include/uapi/ should be exported, so let's
>> use wildcards.
> 
> I think the idea makes a lot of sense: if a header is in uapi, we should
> really export it. However, using a wildcard expression seems a bit
> backwards here, I think we should make this implicit and not have the
> Kbuild file at all.
> 
> The "header-y" syntax was originally added back when the uapi headers
> were mixed with the internal headers in the same directory. After
> David Howells introduced the separate directory for uapi, it has
> become a bit redundant.
Ok, thank you for the explanation, I was wondering why those Kbuild files were
needed.

> 
> Can you try to modify scripts/Makefile.headersinst instead so we
> can simply remove the Kbuild files entirely?
I will try something.


Regards,
Nicolas
