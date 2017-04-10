From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 2/2] bpf: remove struct bpf_map_type_list
Date: Mon, 10 Apr 2017 18:06:06 +0200
Message-ID: <58EBAD6E.2000803@iogearbox.net>
References: <20170410124431.4305-1-johannes@sipsolutions.net> <20170410124431.4305-3-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47997 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751861AbdDJQGN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 12:06:13 -0400
In-Reply-To: <20170410124431.4305-3-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2017 02:44 PM, Johannes Berg wrote:
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

Thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
