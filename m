From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv4 net-next 05/15] bpf: expose internal verfier structures
Date: Thu, 15 Sep 2016 13:09:46 -0700
Message-ID: <20160915200944.GA74433@ast-mbp.thefacebook.com>
References: <1473966755-30106-1-git-send-email-jakub.kicinski@netronome.com>
 <1473966755-30106-6-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34053 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755163AbcIOUJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:09:51 -0400
Received: by mail-pa0-f66.google.com with SMTP id vz6so2521579pab.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:09:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473966755-30106-6-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 08:12:25PM +0100, Jakub Kicinski wrote:
> Move verifier's internal structures to a header file and
> prefix their names with bpf_ to avoid potential namespace
> conflicts.  Those structures will soon be used by external
> analyzers.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> v4:
>  - separate from adding the analyzer;
>  - squash with the prefixing patch.
> ---
>  include/linux/bpf_verifier.h |  78 +++++++++++++
>  kernel/bpf/verifier.c        | 263 +++++++++++++++++--------------------------
>  2 files changed, 180 insertions(+), 161 deletions(-)
>  create mode 100644 include/linux/bpf_verifier.h
> 
> diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
> new file mode 100644
> index 000000000000..1c0511ef7eaf
> --- /dev/null
> +++ b/include/linux/bpf_verifier.h
...
> +#ifndef _LINUX_BPF_ANALYZER_H
> +#define _LINUX_BPF_ANALYZER_H 1

the macro doesn't match the file name.
Other than that
Acked-by: Alexei Starovoitov <ast@kernel.org>
