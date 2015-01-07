From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 2/2] tc: add support for BPF based actions
Date: Wed, 7 Jan 2015 20:52:33 +0100
Message-ID: <20150107195233.GA1898@nanopsycho.orion>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
 <1420649244-9574-1-git-send-email-jiri@resnulli.us>
 <1420649244-9574-2-git-send-email-jiri@resnulli.us>
 <CAHA+R7Pk31fjLm-ksUF-8hQ3+tkqQ-Z820Bayj2n6DTFjNcCsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:50045 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbbAGTwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 14:52:35 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so2406655wiw.4
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 11:52:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAHA+R7Pk31fjLm-ksUF-8hQ3+tkqQ-Z820Bayj2n6DTFjNcCsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 07, 2015 at 07:50:47PM CET, cwang@twopensource.com wrote:
>On Wed, Jan 7, 2015 at 8:47 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> +       fprintf(stderr, "Usage: ... bpf ...\n");
>> +       fprintf(stderr, "\n");
>> +       fprintf(stderr, " [inline]:     run bytecode BPF_BYTECODE\n");
>> +       fprintf(stderr, " [from file]:  run bytecode-file FILE\n");
>> +       fprintf(stderr, "\n");
>> +       fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
>> +       fprintf(stderr, "      c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
>> +       fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string\n");
>> +       fprintf(stderr, "\nACTION_SPEC := ... look at individual actions\n");
>> +       fprintf(stderr, "NOTE: CLASSID is parsed as hexadecimal input.\n");
>
>Can we just use BPF transparently for gact?

Why to squash it there? I think it is much clearer to do this
separatelly.

>It is never user-friendly to
>use this kind of bytecode even though I know there is a tool to "compile"
>BPF.

Please see cls_bpf. It's already in-tree for some time. act_bpf just
completes this.
