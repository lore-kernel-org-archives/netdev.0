From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 08/12] tools: bpftool: add JSON output for `bpftool
 batch file FILE` command
Date: Mon, 23 Oct 2017 22:32:54 +0200
Message-ID: <59EE51F6.10800@iogearbox.net>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com> <20171023162416.32753-9-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41865 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdJWUcz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 16:32:55 -0400
In-Reply-To: <20171023162416.32753-9-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 06:24 PM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> `bpftool batch file FILE` takes FILE as an argument and executes all the
> bpftool commands it finds inside (or stops if an error occurs).
>
> To obtain a consistent JSON output, create a root JSON array, then for
> each command create a new object containing two fields: one with the
> command arguments, the other with the output (which is the JSON object
> that the command would have produced, if called on its own).
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
