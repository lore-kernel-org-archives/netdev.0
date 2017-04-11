From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v4 2/2] bpf: remove struct bpf_map_type_list
Date: Tue, 11 Apr 2017 07:43:17 -0700
Message-ID: <20170411144316.GB10662@ast-mbp.thefacebook.com>
References: <20170411133458.26816-1-johannes@sipsolutions.net>
 <20170411133458.26816-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:32998 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752151AbdDKOnV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:43:21 -0400
Received: by mail-pg0-f44.google.com with SMTP id x125so123627673pgb.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 07:43:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170411133458.26816-2-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 03:34:58PM +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> There's no need to have struct bpf_map_type_list since
> it just contains a list_head, the type, and the ops
> pointer. Since the types are densely packed and not
> actually dynamically registered, it's much easier and
> smaller to have an array of type->ops pointer. Also
> initialize this array statically to remove code needed
> to initialize it.
> 
> In order to save duplicating the list, move it to the
> types header file added by the previous patch and
> include it in the same fashion.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
> v4: add ifdef on CONFIG_PERF_EVENTS for stack_map_ops

I'm ok if you keep my ack after minor changes like this.
Acked-by: Alexei Starovoitov <ast@kernel.org>

saves me typing another email and spamming everyone once more..
