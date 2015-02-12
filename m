From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 7/7] cls_bpf: add initial eBPF support for programmable
 classifiers
Date: Thu, 12 Feb 2015 21:46:20 +0100
Message-ID: <54DD111C.8000304@iogearbox.net>
References: <CAMEtUuzAeukNAynQtMbjLYQcB+kxM+XaFFsB1tvrHjxUskJdZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41325 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbbBLUqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 15:46:32 -0500
In-Reply-To: <CAMEtUuzAeukNAynQtMbjLYQcB+kxM+XaFFsB1tvrHjxUskJdZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2015 03:16 AM, Alexei Starovoitov wrote:
...
> 2.
> in core/filter.c do:
> bpf_register_prog_type(&sock_type);
> bpf_register_prog_type(&cls_type);
> static struct bpf_prog_type_list cls_type = {
>          .ops = &sock_filter_ops,
>          .type = BPF_PROG_TYPE_SCHED_CLS,
> };

Yes, that's fine by me. That way, we'll also preserve ABI compatibility when
we decide to diverge from the current socket filter functionality.
