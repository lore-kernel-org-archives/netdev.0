From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 7/8] tools: bpftool: show that `opcodes` or `file
 FILE` should be exclusive
Date: Fri, 20 Oct 2017 12:56:49 +0200
Message-ID: <59E9D671.6030805@iogearbox.net>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com> <20171019224626.31608-8-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50012 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753073AbdJTK4v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 06:56:51 -0400
In-Reply-To: <20171019224626.31608-8-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 12:46 AM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> For the `bpftool prog dump { jited | xlated } ...` command, adding
> `opcodes` keyword (to request opcodes to be printed) will have no effect
> if `file FILE` (to write binary output to FILE) is provided.
>
> The manual page and the help message to be displayed in the terminal
> should reflect that, and indicate that these options should be mutually
> exclusive.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
