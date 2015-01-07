From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch iproute2 2/2] tc: add support for BPF based actions
Date: Wed, 7 Jan 2015 10:50:47 -0800
Message-ID: <CAHA+R7Pk31fjLm-ksUF-8hQ3+tkqQ-Z820Bayj2n6DTFjNcCsQ@mail.gmail.com>
References: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
	<1420649244-9574-1-git-send-email-jiri@resnulli.us>
	<1420649244-9574-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:45451 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbbAGSus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 13:50:48 -0500
Received: by mail-qc0-f179.google.com with SMTP id c9so1308745qcz.24
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 10:50:47 -0800 (PST)
In-Reply-To: <1420649244-9574-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 8:47 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> +       fprintf(stderr, "Usage: ... bpf ...\n");
> +       fprintf(stderr, "\n");
> +       fprintf(stderr, " [inline]:     run bytecode BPF_BYTECODE\n");
> +       fprintf(stderr, " [from file]:  run bytecode-file FILE\n");
> +       fprintf(stderr, "\n");
> +       fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
> +       fprintf(stderr, "      c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
> +       fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string\n");
> +       fprintf(stderr, "\nACTION_SPEC := ... look at individual actions\n");
> +       fprintf(stderr, "NOTE: CLASSID is parsed as hexadecimal input.\n");

Can we just use BPF transparently for gact? It is never user-friendly to
use this kind of bytecode even though I know there is a tool to "compile"
BPF.
