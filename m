From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] bpf: netdev is never null in __dev_map_flush
Date: Wed, 23 Aug 2017 20:10:15 -0700
Message-ID: <599E4397.5020802@gmail.com>
References: <d8e0306b70b05bdd5e628459863d1027c8c26959.1503537400.git.daniel@iogearbox.net> <1efe2357-43aa-8976-75a0-62d4572287cc@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33417 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdHXDKd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:10:33 -0400
Received: by mail-pg0-f67.google.com with SMTP id 189so1884697pgj.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 20:10:33 -0700 (PDT)
In-Reply-To: <1efe2357-43aa-8976-75a0-62d4572287cc@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2017 06:25 PM, Alexei Starovoitov wrote:
> On 8/23/17 6:20 PM, Daniel Borkmann wrote:
>> No need to test for it in fast-path, every dev in bpf_dtab_netdev
>> is guaranteed to be non-NULL, otherwise dev_map_update_elem() will
>> fail in the first place.
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> 
> wow. interesting. I'm surprised you see a difference from
> such micro-optimization.
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> 
> 

Thanks for the clean up, I was a bit over paranoid here as well. Is
this actually noticeable in pps benchmark or just making the code
cleaner? Just curious.

Acked-by: John Fastabend <john.fastabend@gmail.com>
