From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv5 net-next 07/15] bpf: recognize 64bit immediate loads
 as consts
Date: Fri, 16 Sep 2016 23:37:38 +0200
Message-ID: <57DC6622.3090402@iogearbox.net>
References: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com> <1474018622-10653-8-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42583 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbcIPVhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 17:37:40 -0400
In-Reply-To: <1474018622-10653-8-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2016 11:36 AM, Jakub Kicinski wrote:
> When running as parser interpret BPF_LD | BPF_IMM | BPF_DW
> instructions as loading CONST_IMM with the value stored
> in imm.  The verifier will continue not recognizing those
> due to concerns about search space/program complexity
> increase.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
