From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/3] rhashtable: Get rid of raw table walkers part 1
Date: Fri, 19 Aug 2016 18:34:30 +0200
Message-ID: <20160819163430.GD29430@pox.localdomain>
References: <20160818084854.GA11502@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35159 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754011AbcHSQed (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 12:34:33 -0400
Received: by mail-wm0-f53.google.com with SMTP id f65so41016763wmi.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 09:34:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160818084854.GA11502@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/16 at 04:48pm, Herbert Xu wrote:
> Dave/Tomas, please keep an eye out for any new patches that try
> to introduce raw table walkers and nack them.

Very nice work Herbert. I think we should move the rht_for_each_* macros
to a private header or lib/rhashtable.c to discourage usage altogether.
