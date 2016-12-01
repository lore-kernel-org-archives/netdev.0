From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v7 net-next 2/6] bpf: Add new cgroup attach type to
 enable sock modifications
Date: Thu, 1 Dec 2016 08:56:37 -0800
Message-ID: <20161201165636.GB46200@ast-mbp.thefacebook.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
 <1480610888-31082-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35824 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753150AbcLASAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 13:00:47 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so5271816pga.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 10:00:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480610888-31082-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 08:48:04AM -0800, David Ahern wrote:
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
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
