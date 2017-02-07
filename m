From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [net-next PATCH 0/4] Documenting eBPF - extended Berkeley
 Packet Filter
Date: Tue, 7 Feb 2017 08:37:17 -0700
Message-ID: <20170207083717.1c98f608@lwn.net>
References: <148647756092.10567.10947541548678801938.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>, alexander@alemayhu.com,
        linux-kernel@vger.kernel.org, quentin.monnet@6wind.com,
        Daniel Borkmann <borkmann@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148647756092.10567.10947541548678801938.stgit@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 07 Feb 2017 15:30:11 +0100
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Question: What kernel tree should this go into???
> 
> If going through Jonathan Corbet, will it appear sooner here???
>  https://www.kernel.org/doc/html/latest/
> If it will not appear sooner that way, then it's likely best to keep
> it in sync with the tree that takes eBPF code changes.

I've developed a fairly strong preference for carrying patches touching
index.rst; otherwise I spend a lot of time explaining merge conflicts to
Linus.

If the consensus is that this is ready to go, I expect I can squeeze it in
for 4.11.  I'm not too worried about regressions...:)

I haven't actually built it yet, but from a first look it seems like an
awfully good start.  The one thing that comes to mind is that I'm likely
to want to move it at some point.  I'd really like to start a separate
book for user-space developer documentation, and this would certainly
belong there.  That book doesn't exist yet, though, so I can't quite blame
you, hard as I might try, for not putting this document there.

Thanks,

jon
