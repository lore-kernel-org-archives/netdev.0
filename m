From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: move knowledge about post-translation
 offsets out of verifier
Date: Tue, 17 Oct 2017 11:38:23 +0200
Message-ID: <59E5CF8F.10108@iogearbox.net>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com> <20171016234056.1964-4-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41299 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760536AbdJQJiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 05:38:25 -0400
In-Reply-To: <20171016234056.1964-4-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 01:40 AM, Jakub Kicinski wrote:
> Use the fact that verifier ops are now separate from program
> ops to define a separate set of callbacks for verification of
> already translated programs.
>
> Since we expect the analyzer ops to be defined only for
> a small subset of all program types initialize their array
> by hand (don't use linux/bpf_types.h).
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
