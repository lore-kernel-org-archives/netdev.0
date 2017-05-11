From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] samples/bpf: run cleanup routines when receiving
 SIGTERM
Date: Thu, 11 May 2017 16:16:10 -0700
Message-ID: <20170511231608.6s2juais2aixh65n@ast-mbp>
References: <1494532350-23945-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shahid.habib@broadcom.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36516 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756232AbdEKXQN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 19:16:13 -0400
Received: by mail-pf0-f182.google.com with SMTP id m17so20769805pfg.3
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 16:16:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1494532350-23945-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 11, 2017 at 03:52:30PM -0400, Andy Gospodarek wrote:
> Shahid Habib noticed that when xdp1 was killed from a different console the xdp
> program was not cleaned-up properly in the kernel and it continued to forward
> traffic.
> 
> Most of the applications in samples/bpf cleanup properly, but only when getting
> SIGINT.  Since kill defaults to using SIGTERM, add support to cleanup when the
> application receives either SIGINT or SIGTERM.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Reported-by: Shahid Habib <shahid.habib@broadcom.com>

Thanks for the fix.
Acked-by: Alexei Starovoitov <ast@kernel.org>
