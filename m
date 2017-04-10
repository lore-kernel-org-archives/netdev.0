From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 2/2] bpf: remove struct bpf_map_type_list
Date: Mon, 10 Apr 2017 07:58:36 -0700
Message-ID: <20170410145834.GB41264@ast-mbp.thefacebook.com>
References: <20170410124431.4305-1-johannes@sipsolutions.net>
 <20170410124431.4305-3-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33130 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753861AbdDJO6p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:58:45 -0400
Received: by mail-pg0-f54.google.com with SMTP id x125so107209364pgb.0
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 07:58:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170410124431.4305-3-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 02:44:31PM +0200, Johannes Berg wrote:
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

Acked-by: Alexei Starovoitov <ast@kernel.org>
