From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch iproute2 2/2] tc: add support for BPF based actions
Date: Wed, 7 Jan 2015 11:58:03 -0800
Message-ID: <CAHA+R7OzoMOjkzDraia9g=32uVuDwGv3XQmWdh1vo292FNwv=Q@mail.gmail.com>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
	<1420649244-9574-1-git-send-email-jiri@resnulli.us>
	<1420649244-9574-2-git-send-email-jiri@resnulli.us>
	<CAHA+R7Pk31fjLm-ksUF-8hQ3+tkqQ-Z820Bayj2n6DTFjNcCsQ@mail.gmail.com>
	<20150107195233.GA1898@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:56903 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbAGT6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 14:58:04 -0500
Received: by mail-qa0-f54.google.com with SMTP id i13so4172174qae.13
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 11:58:03 -0800 (PST)
In-Reply-To: <20150107195233.GA1898@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 11:52 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Jan 07, 2015 at 07:50:47PM CET, cwang@twopensource.com wrote:
>>On Wed, Jan 7, 2015 at 8:47 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> +       fprintf(stderr, "Usage: ... bpf ...\n");
>>> +       fprintf(stderr, "\n");
>>> +       fprintf(stderr, " [inline]:     run bytecode BPF_BYTECODE\n");
>>> +       fprintf(stderr, " [from file]:  run bytecode-file FILE\n");
>>> +       fprintf(stderr, "\n");
>>> +       fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
>>> +       fprintf(stderr, "      c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
>>> +       fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string\n");
>>> +       fprintf(stderr, "\nACTION_SPEC := ... look at individual actions\n");
>>> +       fprintf(stderr, "NOTE: CLASSID is parsed as hexadecimal input.\n");
>>
>>Can we just use BPF transparently for gact?
>
> Why to squash it there? I think it is much clearer to do this
> separatelly.
>

Because they are both intended to drop/pass/pipe packets,
we don't have to make a separated one just because one is
using BPF one isn't.

>>It is never user-friendly to
>>use this kind of bytecode even though I know there is a tool to "compile"
>>BPF.
>
> Please see cls_bpf. It's already in-tree for some time. act_bpf just
> completes this.

Yeah, that is what I hate too.
