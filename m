From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] ip: link_ip6tnl.c/ip6tunnel.c:
 Support IP6_TNL_F_ALLOW_LOCAL_REMOTE flag
Date: Tue, 31 Oct 2017 18:16:37 +0100
Message-ID: <20171031181637.08d031c9@shemminger-XPS-13-9360>
References: <20171029155046.16283-1-shmulik@nsof.io>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Shmulik Ladkani <shmulik@nsof.io>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:54540 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753623AbdJaRRD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:17:03 -0400
Received: by mail-lf0-f68.google.com with SMTP id a2so19885462lfh.11
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 10:17:02 -0700 (PDT)
In-Reply-To: <20171029155046.16283-1-shmulik@nsof.io>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 Oct 2017 17:50:46 +0200
Shmulik Ladkani <shmulik@nsof.io> wrote:

> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> IP6_TNL_F_ALLOW_LOCAL_REMOTE allows tunnel traffic on ip6tnl devices
> where the remote endpoint is a local host address.
> 
> Specifying "[no]allow-localremote" controls the
> IP6_TNL_F_ALLOW_LOCAL_REMOTE flag on ip6tnl interfaces.
> 
> This is the user-space counterpart for kernel commit 908d140a87a7 ("ip6_tunnel: Allow rcv/xmit even if remote address is a local address")
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>


Looks good, applied.
Thanks for remembering to update man page as well.
