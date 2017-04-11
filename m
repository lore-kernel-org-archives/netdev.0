From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: reference may_access_skb() from __bpf_prog_run()
Date: Tue, 11 Apr 2017 12:15:23 +0200
Message-ID: <58ECACBB.7080406@iogearbox.net>
References: <20170411101058.13526-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52988 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754107AbdDKKP0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 06:15:26 -0400
In-Reply-To: <20170411101058.13526-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2017 12:10 PM, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> It took me quite some time to figure out how this was linked,
> so in order to save the next person the effort of finding it
> add a comment in __bpf_prog_run() that indicates what exactly
> determines that a program can access the ctx == skb.
>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Makes sense, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
