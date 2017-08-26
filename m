From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 3/8] bpf: Allow cgroup sock filters to use
 get_current_uid_gid helper
Date: Fri, 25 Aug 2017 19:30:13 -0700
Message-ID: <20170826023012.keriwyxtuzvhumhl@ast-mbp>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-4-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35898 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751411AbdHZCaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 22:30:17 -0400
Received: by mail-pf0-f195.google.com with SMTP id a2so149792pfj.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 19:30:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503687941-626-4-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 12:05:36PM -0700, David Ahern wrote:
> Allow BPF programs run on sock create to use the get_current_uid_gid
> helper. IPv4 and IPv6 sockets are created in a process context so
> there is always a valid uid/gid
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
