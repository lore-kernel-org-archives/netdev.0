From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net-next: korina: Fix NAPI versus resources freeing
Date: Wed, 4 Jan 2017 06:24:52 -0800
Message-ID: <9a88ebba-f48b-b3a3-5aee-eec0d6aa6548@gmail.com>
References: <1483522278-36891-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:35980 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031073AbdADO0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 09:26:19 -0500
Received: by mail-oi0-f54.google.com with SMTP id v84so543872903oie.3
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 06:24:54 -0800 (PST)
In-Reply-To: <1483522278-36891-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 01:31 AM, John Crispin wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> 
> Commit beb0babfb77e ("korina: disable napi on close and restart")
> introduced calls to napi_disable() that were missing before,
> unfortunately this leaves a small window during which NAPI has a chance
> to run, yet we just freed resources since korina_free_ring() has been
> called:
> 
> Fix this by disabling NAPI first then freeing resource, and make sure
> that we also cancel the restart taks before doing the resource freeing.
> 
> Fixes: beb0babfb77e ("korina: disable napi on close and restart")

I submitted this patch to 'net' already, but thanks for doing it!
-- 
Florian
