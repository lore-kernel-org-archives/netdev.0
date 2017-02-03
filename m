From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH net-next] bpf: fix verifier issue at check_packet_ptr_add
Date: Fri, 3 Feb 2017 08:20:19 -0800
Message-ID: <CALDO+SbdmEh6paAT-x7PJvJN0ezTk14AmLXTxBtZ_A87PwVtmQ@mail.gmail.com>
References: <1486065553-5074-1-git-send-email-u9012063@gmail.com>
 <5893C4DD.9000701@iogearbox.net> <CALDO+SZCn452+Tp6cBjMb_J9Mu=08Em=0+jsKpa31b3Eoy-0SQ@mail.gmail.com>
 <20170203034636.GA68213@ast-mbp.thefacebook.com> <CALDO+SZrm3KpDDRrC6H9jkaMVxiwUPEFp+1vBaZbSvTdH8=09w@mail.gmail.com>
 <20170203061920.GB80764@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:36172 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbdBCQVG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:21:06 -0500
Received: by mail-it0-f48.google.com with SMTP id c7so14670581itd.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 08:21:01 -0800 (PST)
In-Reply-To: <20170203061920.GB80764@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 10:19 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Feb 02, 2017 at 09:31:06PM -0800, William Tu wrote:
>>
>> Yes, this is auto-generated. We want to use P4 2016 as front end to
>> generate ebpf for XDP.
>
> P4 2016 front-end ? is it public? Is there a 2017 version? ;)
> just curious.
>
the P4_16 is the latest version.
https://github.com/p4lang/p4c
it has ebpf backend for tc, we want to add ebpf backend for xdp.

--William
