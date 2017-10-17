From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/4] bpf: split verifier and program ops
Date: Tue, 17 Oct 2017 08:44:55 -0700
Message-ID: <20171017154452.bqmv2rqjlgonmv5w@ast-mbp.dhcp.thefacebook.com>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
 <20171016234056.1964-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:48467 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933125AbdJQPo5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 11:44:57 -0400
Received: by mail-pf0-f195.google.com with SMTP id b79so1628625pfk.5
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 08:44:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171016234056.1964-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 04:40:53PM -0700, Jakub Kicinski wrote:
> struct bpf_verifier_ops contains both verifier ops and operations
> used later during program's lifetime (test_run).  Split the runtime
> ops into a different structure.
> 
> BPF_PROG_TYPE() will now append ## _prog_ops or ## _verifier_ops
> to the names.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
