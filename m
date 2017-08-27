From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Sun, 27 Aug 2017 08:22:59 -0600
Message-ID: <819aab80-b898-9eb8-36e2-759d2addca0d@gmail.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <59A0D62F.3030806@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        ast@kernel.org, tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36606 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdH0OXB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 10:23:01 -0400
Received: by mail-pf0-f196.google.com with SMTP id a2so2434415pfj.3
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2017 07:23:01 -0700 (PDT)
In-Reply-To: <59A0D62F.3030806@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/17 8:00 PM, Daniel Borkmann wrote:
> Can you elaborate on the semantical changes for the programs
> setting the new flag which are not using below cgroup_bpf_run_filter_sk()
> helper to walk back to root?

You mean other cgroup based programs -- BPF_CGROUP_* ? If so, any reason
not to allow the recursion model on those too?
