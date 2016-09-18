From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv6 net-next 08/15] nfp: add BPF to NFP code translator
Date: Sun, 18 Sep 2016 17:44:56 +0200
Message-ID: <57DEB678.3040705@iogearbox.net>
References: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com> <1474211365-20088-9-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50416 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751476AbcIRPpE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:45:04 -0400
In-Reply-To: <1474211365-20088-9-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2016 05:09 PM, Jakub Kicinski wrote:
> Add translator for JITing eBPF to operations which
> can be executed on NFP's programmable engines.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> v6:
>   - explicitly check for registers >= MAX_BPF_REG;
>   - fix mem leak.

Set looks good to me now, thanks a lot Jakub!

> v4:
>   - use bitfield.h directly.
> v3:
>   - don't clone the program for the verifier (no longer needed);
>   - temporarily add a local copy of macros from bitfield.h.
