From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: add tracepoint in br_fdb_update
Date: Thu, 31 Aug 2017 17:19:33 +0300
Message-ID: <9a4af592-87ce-20cc-d617-b00cb4f72998@cumulusnetworks.com>
References: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch,
        bridge@lists.linux-foundation.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36058 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751392AbdHaOTg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 10:19:36 -0400
Received: by mail-wm0-f46.google.com with SMTP id f127so5868135wmf.1
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 07:19:36 -0700 (PDT)
In-Reply-To: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/17 08:18, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This extends bridge fdb table tracepoints to also cover
> learned fdb entries in the br_fdb_update path. Note that
> unlike other tracepoints I have moved this to when the fdb
> is modified because this is in the datapath and can generate
> a lot of noise in the trace output. br_fdb_update is also called
> from added_by_user context in the NTF_USE case which is already
> traced ..hence the !added_by_user check.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  include/trace/events/bridge.h | 31 +++++++++++++++++++++++++++++++
>  net/bridge/br_fdb.c           |  5 ++++-
>  net/core/net-traces.c         |  1 +
>  3 files changed, 36 insertions(+), 1 deletion(-)
> 

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
