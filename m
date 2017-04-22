From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v2 1/5] nfp: make use of the
 DMA_ATTR_SKIP_CPU_SYNC attribute
Date: Fri, 21 Apr 2017 17:36:25 -0700
Message-ID: <20170421173625.30774a5d@cakuba.lan>
References: <20170421192310.193875-1-jakub.kicinski@netronome.com>
        <20170421192310.193875-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35580 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162726AbdDVAga (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 20:36:30 -0400
Received: by mail-io0-f171.google.com with SMTP id r16so131754662ioi.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 17:36:29 -0700 (PDT)
In-Reply-To: <20170421192310.193875-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Apr 2017 12:23:06 -0700, Jakub Kicinski wrote:
> DMA unmap may destroy changes CPU made to the buffer.  To make XDP
> run correctly on non-x86 platforms we should use the
> DMA_ATTR_SKIP_CPU_SYNC attribute.
> 
> Thanks to using the attribute we can now push the sync operation to the
> common code path from XDP handler.
> 
> A little bit of variable name reshuffling is required to bring the
> code back to readable state.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

I think I need to add the sync for device after XDP DROP as well.

Please drop this series, I'll send v3, sorry.
