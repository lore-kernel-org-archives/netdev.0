From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [net-next PATCH 0/4] Documenting eBPF - extended Berkeley
 Packet Filter
Date: Tue, 7 Feb 2017 14:23:23 -0700
Message-ID: <20170207142323.67f08f47@lwn.net>
References: <148647756092.10567.10947541548678801938.stgit@localhost>
        <20170207083717.1c98f608@lwn.net>
        <20170207170908.492d71c0@redhat.com>
        <20170207094608.60897ee0@lwn.net>
        <20170207215149.55d17098@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>, alexander@alemayhu.com,
        linux-kernel@vger.kernel.org, quentin.monnet@6wind.com,
        Daniel Borkmann <borkmann@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170207215149.55d17098@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Feb 2017 21:51:49 +0100
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> I sounds like Daniel (see other email) have bigger plans for what
> Documentation/BPF/ should contain.  E.g. consolidating
> Documentation/networking/filter.txt which covers the cBPF/eBPF internals.
> If that is the case (and I like the idea), then it goes beyond a
> "userspace-guide".  And perhaps "BPF" is a "book" of its own?

One of the real problems with the kernel's documentation is that there is
really almost no thought given to who the audience is.  We have docs for
kernel developers, for system admins, for user-space developers, etc., and
it's all mixed up into one big jumble.

An objective of mine in launching into this whole project is to try to fix
that, so that people can readily find the documentation they need.  So I
don't think a single top-level directory, with a mix of user-space API
info and "internals", is the right direction to go.  The internals docs
should, IMO, go elsewhere, probably in the core-api manual.

See what I'm getting at here?

> And it seems Daniel is proposing capital-letters BPF for the directory
> name "Documentation/BPF/"?  Any opinions on that? (I'm neutral)

I think we should paint it green; otherwise I'm not too concerned about
this particular point...:)

Thanks,

jon
