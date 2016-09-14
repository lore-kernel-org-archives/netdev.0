From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 2/6] rhashtable: Call library function
 alloc_bucket_locks
Date: Wed, 14 Sep 2016 11:18:26 +0200
Message-ID: <20160914091826.GB11841@pox.localdomain>
References: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
 <1473463197-3076903-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36281 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755834AbcINJS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 05:18:29 -0400
Received: by mail-wm0-f44.google.com with SMTP id b187so36552293wme.1
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 02:18:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473463197-3076903-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/16 at 04:19pm, Tom Herbert wrote:
> To allocate the array of bucket locks for the hash table we now
> call library function alloc_bucket_spinlocks. This function is
> based on the old alloc_bucket_locks in rhashtable and should
> produce the same effect.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
