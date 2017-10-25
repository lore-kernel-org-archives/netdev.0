From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] drivers/net: netronome: Convert timers to use
 timer_setup()
Date: Wed, 25 Oct 2017 09:22:48 -0700
Message-ID: <20171025092248.28ee41d9@cakuba.netronome.com>
References: <20171025105138.GA146561@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:46163 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751898AbdJYQW4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 12:22:56 -0400
Received: by mail-wm0-f68.google.com with SMTP id m72so2982952wmc.1
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 09:22:55 -0700 (PDT)
In-Reply-To: <20171025105138.GA146561@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Oct 2017 03:51:38 -0700, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jiri Pirko <jiri@mellanox.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Simon Horman <simon.horman@netronome.com>
> Cc: oss-drivers@netronome.com
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
