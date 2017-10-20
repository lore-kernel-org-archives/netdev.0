From: James Morris <james.l.morris@oracle.com>
Subject: Re: [PATCH net-next v7 4/5] selinux: bpf: Add selinux check for eBPF
 syscall operations
Date: Fri, 20 Oct 2017 11:57:38 +1100 (AEDT)
Message-ID: <alpine.LFD.2.20.1710201157130.11454@t440.gateway.2wire.net>
References: <20171018200026.146093-1-chenbofeng.kernel@gmail.com> <20171018200026.146093-5-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org,
        Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Paul Moore <paul@paul-moore.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34819 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751406AbdJTA6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 20:58:08 -0400
In-Reply-To: <20171018200026.146093-5-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Oct 2017, Chenbo Feng wrote:

> From: Chenbo Feng <fengc@google.com>
> 
> Implement the actual checks introduced to eBPF related syscalls. This
> implementation use the security field inside bpf object to store a sid that
> identify the bpf object. And when processes try to access the object,
> selinux will check if processes have the right privileges. The creation
> of eBPF object are also checked at the general bpf check hook and new
> cmd introduced to eBPF domain can also be checked there.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>


Reviewed-by: James Morris <james.l.morris@oracle.com>

-- 
James Morris
<james.l.morris@oracle.com>
