From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] tcp: Use pI6c in tcp tracepoint
Date: Mon, 16 Oct 2017 15:33:31 -0700
Message-ID: <20171016223329.intpg2utnzejlnoe@ast-mbp.dhcp.thefacebook.com>
References: <1508189042-19591-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:44376 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752381AbdJPWde (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 18:33:34 -0400
Received: by mail-pg0-f68.google.com with SMTP id j3so7960500pga.1
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 15:33:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508189042-19591-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 02:24:02PM -0700, David Ahern wrote:
> The compact form for IPv6 addresses is more user friendly than the full
> version. For example:
>    compact: 2001:db8:1::1
>       full: 2001:0db8:0001:0000:0000:0000:0000:0004i
> 
> Update the tcp tracepoint to show the compact form.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

nice improvement.
Acked-by: Alexei Starovoitov <ast@kernel.org>
