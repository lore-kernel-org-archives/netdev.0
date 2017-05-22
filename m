From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Accept packets that the H.245 ALG can't process
Date: Mon, 22 May 2017 12:25:06 +0300
Message-ID: <6540ef8b-6848-fb2e-3479-a2bb3d553de4@cogentembedded.com>
References: <20170522020753.16712-1-blair.steven@alliedtelesis.co.nz>
 <20170522020753.16712-2-blair.steven@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Blair Steven <blair.steven@alliedtelesis.co.nz>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:36467 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752693AbdEVJZG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 05:25:06 -0400
Received: by mail-lf0-f54.google.com with SMTP id h4so27562811lfj.3
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 02:25:05 -0700 (PDT)
In-Reply-To: <20170522020753.16712-2-blair.steven@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 5/22/2017 5:07 AM, Blair Steven wrote:

> When two VoIP end points are configured differently (fast connect /
> not fast connect) the ALG was failing to find a matching expectation
> and dropping packets in one direction.
>
> Dropping packets not the job of an ALG, and as such the behaviour

    s/not/is not/. Perhaps could be fixed while applying...

> has been changed to allow the packet to be send to the forwarding
> engine.
>
> Signed-off-by: Blair Steven <blair.steven@alliedtelesis.co.nz>
[...]

MBR, Sergei
