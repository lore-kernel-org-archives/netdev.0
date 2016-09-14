From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 1/6] spinlock: Add library function to allocate
 spinlock buckets array
Date: Wed, 14 Sep 2016 11:27:22 +0200
Message-ID: <20160914092722.GD11841@pox.localdomain>
References: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
 <1473463197-3076903-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37653 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755890AbcINJ11 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 05:27:27 -0400
Received: by mail-wm0-f49.google.com with SMTP id c131so18571872wmh.0
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 02:27:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473463197-3076903-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/16 at 04:19pm, Tom Herbert wrote:
> Add two new library functions alloc_bucket_spinlocks and
> free_bucket_spinlocks. These are use to allocate and free an array
> of spinlocks that are useful as locks for hash buckets. The interface
> specifies the maximum number of spinlocks in the array as well
> as a CPU multiplier to derive the number of spinlocks to allocate.
> The number to allocated is rounded up to a power of two to make
> the array amenable to hash lookup.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
