From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] bpf: remove struct bpf_prog_type_list
Date: Mon, 10 Apr 2017 07:56:47 -0700
Message-ID: <20170410145645.GA41264@ast-mbp.thefacebook.com>
References: <20170410124431.4305-1-johannes@sipsolutions.net>
 <20170410124431.4305-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36374 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753638AbdDJO4v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:56:51 -0400
Received: by mail-pf0-f196.google.com with SMTP id i5so6630119pfc.3
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 07:56:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170410124431.4305-2-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 02:44:30PM +0200, Johannes Berg wrote:
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

looks great. Excellent cleanup.

Acked-by: Alexei Starovoitov <ast@kernel.org>
