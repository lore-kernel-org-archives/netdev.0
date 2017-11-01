From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] security: bpf: replace include of linux/bpf.h
 with forward declarations
Date: Wed, 01 Nov 2017 21:28:57 +0100
Message-ID: <59FA2E89.3060202@iogearbox.net>
References: <20171101184800.16416-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Chenbo Feng <fengc@google.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36600 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933035AbdKAU3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 16:29:00 -0400
In-Reply-To: <20171101184800.16416-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2017 07:48 PM, Jakub Kicinski wrote:
> Touching linux/bpf.h makes us rebuild a surprisingly large
> portion of the kernel.  Remove the unnecessary dependency
> from security.h, it only needs forward declarations.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
