From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Tue, 25 Oct 2016 16:39:47 -0700
Message-ID: <1477438787.7065.158.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
         <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35721 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbcJYXjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 19:39:49 -0400
Received: by mail-pf0-f194.google.com with SMTP id s8so20844013pfj.2
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 16:39:49 -0700 (PDT)
In-Reply-To: <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-25 at 15:30 -0700, David Ahern wrote:
> Add new cgroup based program type, BPF_PROG_TYPE_CGROUP_SOCK. Similar to
> BPF_PROG_TYPE_CGROUP_SKB programs can be attached to a cgroup and run
> any time a process in the cgroup opens an AF_INET or AF_INET6 socket.
> Currently only sk_bound_dev_if is exported to userspace for modification
> by a bpf program.
> 
> This allows a cgroup to be configured such that AF_INET{6} sockets opened
> by processes are automatically bound to a specific device. In turn, this
> enables the running of programs that do not support SO_BINDTODEVICE in a
> specific VRF context / L3 domain.

Does this mean that these programs no longer can use loopback ?
