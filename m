From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 4/5] bpf/verifier: remove varlen_map_value_access
 flag
Date: Wed, 23 Aug 2017 16:44:37 +0200
Message-ID: <599D94D5.60300@iogearbox.net>
References: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com> <34d97e19-2de8-d336-ba13-77d3b02c5f20@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Edward Cree <ecree@solarflare.com>, davem@davemloft.net,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45523 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753985AbdHWOor (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:44:47 -0400
In-Reply-To: <34d97e19-2de8-d336-ba13-77d3b02c5f20@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2017 04:10 PM, Edward Cree wrote:
> The optimisation it does is broken when the 'new' register value has a
>   variable offset and the 'old' was constant.  I broke it with my pointer
>   types unification (see Fixes tag below), before which the 'new' value
>   would have type PTR_TO_MAP_VALUE_ADJ and would thus not compare equal;
>   other changes in that patch mean that its original behaviour (ignore
>   min/max values) cannot be restored.
> Tests on a sample set of cilium programs show no change in count of
>   processed instructions.
>
> Fixes: f1174f77b50c ("bpf/verifier: rework value tracking")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
