From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -net-next] lwt: BPF support for LWT
Date: Mon, 12 Dec 2016 15:41:34 -0800
Message-ID: <20161212154134.51638dae@xeon-e3>
References: <43d8d9ddc604f83e9abff9f998b9581210529c30.1481501217.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35488 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932540AbcLMRo0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 12:44:26 -0500
Received: by mail-pg0-f43.google.com with SMTP id p66so49883025pga.2
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 09:44:26 -0800 (PST)
In-Reply-To: <43d8d9ddc604f83e9abff9f998b9581210529c30.1481501217.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Dec 2016 01:14:35 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> +
> +static int lwt_parse_bpf(struct rtattr *rta, size_t len, int *argcp, char ***argvp,
> +			 int attr, const enum bpf_prog_type bpf_type)

Please break long lines like this.


> +
> +	/* argv is currently the first unparsed argument,
> +	 * but the lwt_parse_encap() caller will move to the next,
> +	 * so step back */
> +	*argcp = argc + 1;

iproute2 uses kernel comment style. 

I went ahead and fixed these.
