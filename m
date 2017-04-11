From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] bpf: remove struct bpf_prog_type_list
Date: Tue, 11 Apr 2017 07:41:41 -0700
Message-ID: <20170411144139.GA10662@ast-mbp.thefacebook.com>
References: <20170411133458.26816-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33964 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdDKOlq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:41:46 -0400
Received: by mail-pf0-f196.google.com with SMTP id o126so13647773pfb.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 07:41:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170411133458.26816-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 03:34:57PM +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> There's no need to have struct bpf_prog_type_list since
> it just contains a list_head, the type, and the ops
> pointer. Since the types are densely packed and not
> actually dynamically registered, it's much easier and
> smaller to have an array of type->ops pointer. Also
> initialize this array statically to remove code needed
> to initialize it.
> 
> In order to save duplicating the list, move it to a new
> header file and include it in the places needing it.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

since there were no changes to the patch, plese carry over the acks:
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
