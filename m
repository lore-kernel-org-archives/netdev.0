From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 0/2] tools: add bpftool
Date: Tue, 26 Sep 2017 17:32:31 -0600
Message-ID: <5522855a-937f-b2cb-4c74-3448d1680b10@gmail.com>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        davem@davemloft.net, hannes@stressinduktion.org,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38021 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030560AbdIZXce (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 19:32:34 -0400
Received: by mail-pg0-f66.google.com with SMTP id m30so7597672pgn.5
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 16:32:33 -0700 (PDT)
In-Reply-To: <20170926153522.31500-1-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/26/17 9:35 AM, Jakub Kicinski wrote:
> I'm looking for a home for bpftool, Daniel suggested that 
> tools/net could be a good place, since there are only BPF
> utilities there already.
> 
> The tool should be complete for simple use cases and we
> will continue extending it as we go along.  E.g. providing
> disassembly of loaded programs directly using LLVM library
> and JSON output are high on the priority list.

I have found this to be a very useful tool. Thanks for working on it.
Moving it into the kernel will make it easier to build since it relies
on libbpf and other files from the kernel tree.

One change I have made locally is to link against libbpf.a. That way I
only need to copy one file to a system to use it.
