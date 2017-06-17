From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] loopback: Force LOOPBACK_IFINDEX for registration
Date: Sat, 17 Jun 2017 14:21:35 +0300
Message-ID: <5c004fd3-07a6-d721-9d08-b78ef967f374@cogentembedded.com>
References: <1497615003-24762-1-git-send-email-serhe.popovych@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Serhey Popovych <serhe.popovych@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:36645 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752762AbdFQLVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 07:21:39 -0400
Received: by mail-lf0-f52.google.com with SMTP id o83so35769019lff.3
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 04:21:39 -0700 (PDT)
In-Reply-To: <1497615003-24762-1-git-send-email-serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 6/16/2017 3:10 PM, Serhey Popovych wrote:

> Now with commit 9c7dafb (net: Allow to create links with

    The commit citing style is standardized: 12-digit SHA1 and the summary 
enclosed in ("").

> given ifindex) support registration of network devices

    Support for.

> with specific ifindex is added.

    Was added.

> We can force loopback network device index before call to
> register_netdev() to ensure we always configure it with
> LOOPBACK_IFINDEX.
>
> Kill BUG_ON() since system can continue without network
> namespace failed in loopback init path, unless it is
> init_net namespace where we panic() anyway.
>
> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
[...]

MBR, Sergei
