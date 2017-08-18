From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: check type when freeing metadata dst
Date: Fri, 18 Aug 2017 15:25:53 +0300
Message-ID: <a983211c-530a-8f73-ed00-c95840ce3d08@cogentembedded.com>
References: <20170818121651.516877-1-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Sridhar Samudrala <sridhar.samudrala@intel.com>,
        Simon Horman <horms@verge.net.au>,
        "David S . Miller" <davem@davemloft.net>
To: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:37421 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbdHRMZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 08:25:57 -0400
Received: by mail-lf0-f49.google.com with SMTP id f7so22034824lfg.4
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 05:25:56 -0700 (PDT)
In-Reply-To: <20170818121651.516877-1-equinox@diac24.net>
Content-Language: en-MW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 08/18/2017 03:16 PM, David Lamparter wrote:

> There is a new metadata dst type field added in "net: store
> port/representator id in metadata_dst", but metadata_dst_free() wasn't
> updated to check it before freeing the METADATA_IP_TUNNEL specific dst
> cache entry.
> 
> This is not currently causing problems since it's far enough back in the
> struct to be zeroed for the only other type currently in existance
> (METADATA_HW_PORT_MUX), but nevertheless it's not correct.
> 
> Fixes: 3fcece12bc1b6dcdf0986f2cd9e8f63b1f9b6aa0

    Please see Documentation/process/submitting-patches.rst on how this tag 
(and the commit citing in your description as well) should look like.

> Signed-off-by: David Lamparter <equinox@diac24.net>
> Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
> Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: David S. Miller <davem@davemloft.net>

[...]

MBR, Sergei
