From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -net-next] bpf: make tc's bpf loader generic
 and move into lib
Date: Tue, 29 Nov 2016 12:37:53 -0800
Message-ID: <20161129123753.79ee1dfb@samsung9>
References: <32ad4312197becd442b8bf136ded8859dd593340.1478736685.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34991 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757020AbcK2Uh4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:37:56 -0500
Received: by mail-pg0-f52.google.com with SMTP id p66so73186422pga.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:37:56 -0800 (PST)
In-Reply-To: <32ad4312197becd442b8bf136ded8859dd593340.1478736685.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Nov 2016 01:20:59 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> This work moves the bpf loader into the iproute2 library and reworks
> the tc specific parts into generic code. It's useful as we can then
> more easily support new program types by just having the same ELF
> loader backend. Joint work with Thomas Graf. I hacked a rough start
> of a test suite to make sure nothing breaks [1] and looks all good.
> 
>   [1] https://github.com/borkmann/clsact/blob/master/test_bpf.sh
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied to net-next, will push soon.
