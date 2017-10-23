From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 00/12] tools: bpftool: Add JSON output to bpftool
Date: Mon, 23 Oct 2017 10:44:18 -0700
Message-ID: <20171023174416.tjukqbiyune5zrb6@ast-mbp.dhcp.thefacebook.com>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:56344 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932117AbdJWRoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 13:44:22 -0400
Received: by mail-pf0-f174.google.com with SMTP id b85so17618150pfj.13
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 10:44:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 09:24:04AM -0700, Jakub Kicinski wrote:
> Quentin says:
> 
> This series introduces support for JSON output to all bpftool commands. It
> adds option parsing, and several options are created:
> 
>   * -j, --json     Switch to JSON output.
>   * -p, --pretty   Switch to JSON and print it in a human-friendly fashion.
>   * -h, --help     Print generic help message.
>   * -V, --version  Print version number.
> 
> This code uses a "json_writer", which is a copy of the one written by
> Stephen Hemminger in iproute2.
> ---
> I don't know if there is an easy way to share the code for json_write
> without copying the file, so I am very open to suggestions on this matter.

I think copy-paste is fine in this case.
If we ever decide to remove it from here and move it into iproute2
this json.[hc] can be unified, but I think kernel/tools/bpf/ is
a better place since introspection interface is still evolving a lot
and bpftool is not networking specific. Like would be great if it
can show what programs attached to which cgroups, tracepoints, kprobes.

Overall looks like a nice set of improvements.

Acked-by: Alexei Starovoitov <ast@kernel.org>
