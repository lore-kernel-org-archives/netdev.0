From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: reduce compiler warnings by adding fallthrough
 comments
Date: Mon, 13 Feb 2017 16:00:06 -0800
Message-ID: <20170214000004.GA37569@ast-mbp.thefacebook.com>
References: <20170213230235.12677-1-alexander@alemayhu.com>
 <58A23EAD.6040800@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Alemayhu <alexander@alemayhu.com>,
        netdev@vger.kernel.org, ast@kernel.org, brouer@redhat.com,
        dcb314@hotmail.com, jbacik@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32826 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751394AbdBNAAM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 19:00:12 -0500
Received: by mail-it0-f67.google.com with SMTP id e137so1398246itc.0
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 16:00:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <58A23EAD.6040800@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 12:18:05AM +0100, Daniel Borkmann wrote:
> >kernel/bpf/verifier.c:2019:24: warning: this statement may fall through [-Wimplicit-fallthrough=]
> >    false_reg->min_value = 0;
> >    ~~~~~~~~~~~~~~~~~~~~~^~~
> >
> >Reported-by: David Binderman <dcb314@hotmail.com>
> >Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
> 
> These fall-through comments are fine for net-next tree.
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

lgtm as well
Acked-by: Alexei Starovoitov <ast@kernel.org>
