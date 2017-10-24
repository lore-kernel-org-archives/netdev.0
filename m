From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 1/2] net: updating dst lastusage is an unlikely
 event.
Date: Tue, 24 Oct 2017 12:39:45 +0200
Message-ID: <1508841585.2758.10.camel@redhat.com>
References: <cb6e9e39bdcdaebba87e331d7b18392bdeefebc3.1508841315.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>, Martin KaFai Lau <kafai@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50136 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751753AbdJXKjs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 06:39:48 -0400
In-Reply-To: <cb6e9e39bdcdaebba87e331d7b18392bdeefebc3.1508841315.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-24 at 12:37 +0200, Paolo Abeni wrote:
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

Oops, I placed a bad subject prefix here, please ignore. I'll resend
soon with a proper one.

Sorry for the noise,

Paolo 
