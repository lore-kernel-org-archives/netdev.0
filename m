From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] cgroup, bpf: remove unnecessary #include
Date: Tue, 29 Nov 2016 11:26:35 -0800
Message-ID: <CAADnVQL4-P5-z7XYhTz0vTo-3TzrSGwV1frQMFKb-DuXXa2B3w@mail.gmail.com>
References: <1480145027-3524392-1-git-send-email-ast@fb.com> <583D5D00.4070101@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Mack <daniel@zonque.org>, Tejun Heo <tj@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36718 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755923AbcK2T06 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 14:26:58 -0500
Received: by mail-lf0-f67.google.com with SMTP id o20so13660548lfg.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 11:26:57 -0800 (PST)
In-Reply-To: <583D5D00.4070101@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 2:48 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 11/26/2016 08:23 AM, Alexei Starovoitov wrote:
>>
>> this #include is unnecessary and brings whole set of
>> other headers into cgroup-defs.h. Remove it.
>>
>> Fixes: 3007098494be ("cgroup: add support for eBPF programs")
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>
>
> This fixes many build errors in samples/bpf/ due to wrong helper
> redefinitions (originating from kernel includes conflicting with
> samples' helper declarations).
>
> I don't see it pushed out to net-next yet, so:
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Dave,
this patch is marked as 'accepted', but I don't see in net-next ...
please double check.
Thanks!
