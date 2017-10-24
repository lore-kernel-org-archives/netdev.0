From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] tools: bpftool: Add JSON output to
 bpftool
Date: Tue, 24 Oct 2017 01:25:30 +0100 (WEST)
Message-ID: <20171024.012530.1021507145650149983.davem@davemloft.net>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdJXAZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 20:25:35 -0400
In-Reply-To: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 23 Oct 2017 09:24:04 -0700

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

Series applied.
