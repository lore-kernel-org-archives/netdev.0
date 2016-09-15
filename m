From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv4 net-next 06/15] bpf: enable non-core use of the verfier
Date: Thu, 15 Sep 2016 13:10:31 -0700
Message-ID: <20160915201030.GB74433@ast-mbp.thefacebook.com>
References: <1473966755-30106-1-git-send-email-jakub.kicinski@netronome.com>
 <1473966755-30106-7-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33304 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753552AbcIOUKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:10:36 -0400
Received: by mail-pa0-f47.google.com with SMTP id cm16so18926747pac.0
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:10:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473966755-30106-7-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 08:12:26PM +0100, Jakub Kicinski wrote:
> Advanced JIT compilers and translators may want to use
> eBPF verifier as a base for parsers or to perform custom
> checks and validations.
> 
> Add ability for external users to invoke the verifier
> and provide callbacks to be invoked for every intruction
> checked.  For now only add most basic callback for
> per-instruction pre-interpretation checks is added.  More
> advanced users may also like to have per-instruction post
> callback and state comparison callback.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> v4:
>  - separate from the header split patch.

Acked-by: Alexei Starovoitov <ast@kernel.org>
