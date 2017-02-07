From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [net-next PATCH 0/4] Documenting eBPF - extended Berkeley
 Packet Filter
Date: Tue, 7 Feb 2017 09:46:08 -0700
Message-ID: <20170207094608.60897ee0@lwn.net>
References: <148647756092.10567.10947541548678801938.stgit@localhost>
        <20170207083717.1c98f608@lwn.net>
        <20170207170908.492d71c0@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>, alexander@alemayhu.com,
        linux-kernel@vger.kernel.org, quentin.monnet@6wind.com,
        Daniel Borkmann <borkmann@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170207170908.492d71c0@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Feb 2017 17:09:08 +0100
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > > Question: What kernel tree should this go into???
> > > 
> > > If going through Jonathan Corbet, will it appear sooner here???
> > >  https://www.kernel.org/doc/html/latest/  
> 
> What about this question?  Or let me ask in another way, what tree is
> https://www.kernel.org/doc/html/latest/ based on?

I believe it's generated from the current -rc.  If this stuff goes into
4.11, it should show up there next week.

> Yes, I was also wondering hard where to put it... and a book for
> user-space developer documentation would likely be the right place, but
> it was not there, as you mention ;-) 
> 
> I'm fine with moving it later under another "book". Linking to it as
> HTML would still be the same right? (https://www.kernel.org/doc/html/latest/bpf/index.html)
> And is the Documentation/bpf/ directory the correct place?

Moving it would change the URL, of course.  If we want to avoid that, we
should try to come up with the proper placement from the outset.  And we
would want to move it; I really want to clean up the mess that is the
top-level directory.

How about if it goes into Documentation/userspace-guide/bpf ?  The
intermediate directory could just be empty for now, I'll put the book
structure into place later on.  Then the URL for the BPF guide itself
wouldn't change.

jon
