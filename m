From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 09/12] tools: bpftool: turn err() and info()
 macros into functions
Date: Mon, 23 Oct 2017 22:33:35 +0200
Message-ID: <59EE521F.2000902@iogearbox.net>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com> <20171023162416.32753-10-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41991 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdJWUdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 16:33:36 -0400
In-Reply-To: <20171023162416.32753-10-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 06:24 PM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> Turn err() and info() macros into functions.
>
> In order to avoid naming conflicts with variables in the code, rename
> them as p_err() and p_info() respectively.
>
> The behavior of these functions is similar to the one of the macros for
> plain output. However, when JSON output is requested, these macros
> return a JSON-formatted "error" object instead of printing a message to
> stderr.
>
> To handle error messages correctly with JSON, a modification was brought
> to their behavior nonetheless: the functions now append a end-of-line
> character at the end of the message. This way, we can remove end-of-line
> characters at the end of the argument strings, and not have them in the
> JSON output.
>
> All error messages are formatted to hold in a single call to p_err(), in
> order to produce a single JSON field.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
> Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
