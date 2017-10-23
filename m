From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 18/27] bpf: Restrict kernel image access functions when the kernel is locked down
Date: Mon, 23 Oct 2017 15:51:18 +0100
Message-ID: <21228.1508770278@warthog.procyon.org.uk>
References: <20171020230040.qlz5rnegldcpzzb7@ast-mbp> <20171020024732.GJ3285@linux-l9pv.suse> <150842463163.7923.11081723749106843698.stgit@warthog.procyon.org.uk> <150842476953.7923.18174368926573855810.stgit@warthog.procyon.org.uk> <20171019221829.7m5nczg3ltqmhzom@ast-mbp> <2582.1508486928@warthog.procyon.org.uk> <20171020155748.kzrvg6565oxh6gmb@linux-rasp2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, jlee@suse.com, linux-kernel@vger.kernel.org,
        jforbes@redhat.com, Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Gary Lin <GLin@suse.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020230040.qlz5rnegldcpzzb7@ast-mbp>
Content-ID: <21227.1508770278.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> If you want to lock down read access you'd need to disable
> not only bpf, but all of kprobe and likey ftrace, since
> untrusted root can infer kernel data by observing function
> execution even if it cannot load modules and bpf progs.

Okay.

David
