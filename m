From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] Don't allow overwrite of config src addr
Date: Mon, 20 Feb 2017 22:35:20 +0300
Message-ID: <58ee16db-7ab5-408d-46f6-371f04dce8d2@cogentembedded.com>
References: <1487610234-8239-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Brian Russell <brussell@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:36000 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbdBTTfZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 14:35:25 -0500
Received: by mail-lf0-f44.google.com with SMTP id b80so17733040lfe.3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 11:35:24 -0800 (PST)
In-Reply-To: <1487610234-8239-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 02/20/2017 08:03 PM, Brian Russell wrote:

> When using IPv6 transport and a default dst, a pointer to the configured
> source address is passed into the route lookup. If no source address is
> configured, then the value is overwritten.
>
> IPv6 route lookup ignores egress ifindex match if the source adress is set,

    Address. Perhaps can be fixed while applying?

> so if egress ifindex match is desired, the source address must be passed
> as any. The overwrite breaks this for subsequent lookups.
>
> Avoid this by copying the configured address to an existing stack variable
> and pass a pointer to that instead.
>
> Signed-off-by: Brian Russell <brussell@brocade.com>
[...]

MBR, Sergei
