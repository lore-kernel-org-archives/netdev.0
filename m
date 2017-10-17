From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/4] bpf: split verifier and program ops
Date: Tue, 17 Oct 2017 11:37:56 +0200
Message-ID: <59E5CF74.3020907@iogearbox.net>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com> <20171016234056.1964-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41240 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753108AbdJQJh7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 05:37:59 -0400
In-Reply-To: <20171016234056.1964-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 01:40 AM, Jakub Kicinski wrote:
> struct bpf_verifier_ops contains both verifier ops and operations
> used later during program's lifetime (test_run).  Split the runtime
> ops into a different structure.
>
> BPF_PROG_TYPE() will now append ## _prog_ops or ## _verifier_ops
> to the names.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
