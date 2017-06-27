From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] bpf: indicate lderr when bpf_apply_relo_data
 fails
Date: Wed, 28 Jun 2017 01:14:33 +0200
Message-ID: <5952E6D9.3010201@iogearbox.net>
References: <e9c3ce47faaef896a30df16e72a9861ee59069dc.1498524386.git.daniel@iogearbox.net> <20170627160939.236fae90@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36891 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753830AbdF0XOf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:14:35 -0400
In-Reply-To: <20170627160939.236fae90@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2017 01:09 AM, Stephen Hemminger wrote:
> On Tue, 27 Jun 2017 02:48:36 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> When LLVM wrongly generates a rodata relo entry (llvm BZ #33599),
>> then just bail out instead of probing for prog w/o reloc, which
>> will fail in this case anyway.
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Applied, but don't you want a reasonable error message.

Thanks, the error message in this case throws:

ELF contains non-map related relo data in entry <X> pointing to section <Y>! Compiler bug?!
