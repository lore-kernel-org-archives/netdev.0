From: James Morris <james.l.morris@oracle.com>
Subject: Re: [PATCH net-next v7 5/5] selinux: bpf: Add addtional check for
 bpf object file receive
Date: Fri, 20 Oct 2017 12:28:50 +1100 (AEDT)
Message-ID: <alpine.LFD.2.20.1710201228150.11454@t440.gateway.2wire.net>
References: <20171018200026.146093-1-chenbofeng.kernel@gmail.com> <20171018200026.146093-6-chenbofeng.kernel@gmail.com>
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
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20171018200026.146093-6-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Oct 2017, Chenbo Feng wrote:

> From: Chenbo Feng <fengc@google.com>
> 
> Introduce a bpf object related check when sending and receiving files
> through unix domain socket as well as binder. It checks if the receiving
> process have privilege to read/write the bpf map or use the bpf program.
> This check is necessary because the bpf maps and programs are using a
> anonymous inode as their shared inode so the normal way of checking the
> files and sockets when passing between processes cannot work properly on
> eBPF object. This check only works when the BPF_SYSCALL is configured.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>
> Acked-by: Stephen Smalley <sds@tycho.nsa.gov>



Reviewed-by: James Morris <james.l.morris@oracle.com>


-- 
James Morris
<james.l.morris@oracle.com>

