From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/4] bpf: remove the verifier ops from program
 structure
Date: Tue, 17 Oct 2017 08:45:12 -0700
Message-ID: <20171017154511.zxzzezasfxjksp5f@ast-mbp.dhcp.thefacebook.com>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
 <20171016234056.1964-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:56193 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753401AbdJQPpO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 11:45:14 -0400
Received: by mail-pf0-f193.google.com with SMTP id 17so1615628pfn.12
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 08:45:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171016234056.1964-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 04:40:54PM -0700, Jakub Kicinski wrote:
> Since the verifier ops don't have to be associated with
> the program for its entire lifetime we can move it to
> verifier's struct bpf_verifier_env.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
