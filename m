From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bpf: indicate lderr when bpf_apply_relo_data
 fails
Date: Tue, 27 Jun 2017 16:09:39 -0700
Message-ID: <20170627160939.236fae90@xeon-e3>
References: <e9c3ce47faaef896a30df16e72a9861ee59069dc.1498524386.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33527 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753880AbdF0XJm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:09:42 -0400
Received: by mail-pg0-f46.google.com with SMTP id f127so22495162pgc.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:09:41 -0700 (PDT)
In-Reply-To: <e9c3ce47faaef896a30df16e72a9861ee59069dc.1498524386.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jun 2017 02:48:36 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> When LLVM wrongly generates a rodata relo entry (llvm BZ #33599),
> then just bail out instead of probing for prog w/o reloc, which
> will fail in this case anyway.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, but don't you want a reasonable error message.
