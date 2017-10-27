From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: updating dst lastusage is an unlikely
 event.
Date: Fri, 27 Oct 2017 11:53:54 +0900 (KST)
Message-ID: <20171027.115354.2129010929524093978.davem@davemloft.net>
References: <cb6e9e39bdcdaebba87e331d7b18392bdeefebc3.1508841595.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weiwan@google.com, kafai@fb.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932334AbdJ0CyA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 22:54:00 -0400
In-Reply-To: <cb6e9e39bdcdaebba87e331d7b18392bdeefebc3.1508841595.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 24 Oct 2017 12:41:01 +0200

> Since commit 0da4af00b2ed ("ipv6: only update __use and lastusetime
> once per jiffy at most"), updating the dst lastuse field is an
> unlikely action: it happens at most once per jiffy, out of
> potentially millions of calls per second.
> 
> Mark explicitly the code as such, and let the compiler generate
> better code.
> 
> Note: gcc 7.2 and several older versions do actually generate
> different - better - code when the unlikely() hint is in place,
> avoid jump in the fast path and keeping better code locality.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
