From: James Morris <james.l.morris@oracle.com>
Subject: Re: [PATCH net-next v7 3/5] security: bpf: Add LSM hooks for bpf
 object related syscall
Date: Fri, 20 Oct 2017 11:54:20 +1100 (AEDT)
Message-ID: <alpine.LFD.2.20.1710201153050.11171@t440.gateway.2wire.net>
References: <20171018200026.146093-1-chenbofeng.kernel@gmail.com> <20171018200026.146093-4-chenbofeng.kernel@gmail.com>
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
Received: from aserp1040.oracle.com ([141.146.126.69]:33893 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750993AbdJTAy5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 20:54:57 -0400
In-Reply-To: <20171018200026.146093-4-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Oct 2017, Chenbo Feng wrote:

> From: Chenbo Feng <fengc@google.com>
> 
> Introduce several LSM hooks for the syscalls that will allow the
> userspace to access to eBPF object such as eBPF programs and eBPF maps.
> The security check is aimed to enforce a per object security protection
> for eBPF object so only processes with the right priviliges can
> read/write to a specific map or use a specific eBPF program. Besides
> that, a general security hook is added before the multiplexer of bpf
> syscall to check the cmd and the attribute used for the command. The
> actual security module can decide which command need to be checked and
> how the cmd should be checked.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>


Acked-by: James Morris <james.l.morris@oracle.com>

-- 
James Morris
<james.l.morris@oracle.com>
