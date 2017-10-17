From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 3/4] bpf: move knowledge about post-translation
 offsets out of verifier
Date: Tue, 17 Oct 2017 08:45:29 -0700
Message-ID: <20171017154527.qvwa63bnmschnzur@ast-mbp.dhcp.thefacebook.com>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
 <20171016234056.1964-4-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:50003 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933245AbdJQPpb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 11:45:31 -0400
Received: by mail-pf0-f175.google.com with SMTP id i5so1624562pfe.6
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 08:45:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171016234056.1964-4-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 04:40:55PM -0700, Jakub Kicinski wrote:
> Use the fact that verifier ops are now separate from program
> ops to define a separate set of callbacks for verification of
> already translated programs.
> 
> Since we expect the analyzer ops to be defined only for
> a small subset of all program types initialize their array
> by hand (don't use linux/bpf_types.h).
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
