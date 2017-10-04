From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v3 3/3] tools: bpftool: add documentation
Date: Wed, 4 Oct 2017 13:02:38 -0700
Message-ID: <20171004130238.4b83e8c0@cakuba.netronome.com>
References: <20171004154032.11413-1-jakub.kicinski@netronome.com>
        <20171004154032.11413-4-jakub.kicinski@netronome.com>
        <20171004203642.699f5f1a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, dsahern@gmail.com, oss-drivers@netronome.com,
        David Beckett <david.beckett@netronome.com>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20171004203642.699f5f1a@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Oct 2017 20:36:42 +0200, Jesper Dangaard Brouer wrote:
> On Wed,  4 Oct 2017 08:40:32 -0700
> Jakub Kicinski <jakub.kicinski@netronome.com> wrote:
> 
> > Add documentation for bpftool.  Separate files for each subcommand.
> > Use rst format.  Documentation is compiled into man pages using
> > rst2man.
> > 
> > Signed-off-by: David Beckett <david.beckett@netronome.com>
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > Acked-by: Alexei Starovoitov <ast@kernel.org>
> > Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> > ---
> >  tools/bpf/bpftool/Documentation/Makefile         |  34 +++++++
> >  tools/bpf/bpftool/Documentation/bpftool-map.txt  | 110 +++++++++++++++++++++++
> >  tools/bpf/bpftool/Documentation/bpftool-prog.txt |  79 ++++++++++++++++
> >  tools/bpf/bpftool/Documentation/bpftool.txt      |  34 +++++++  
> 
> RST-format files are usually called .rst and not .txt
> 
> This is useful when people happen to browse the code via github, then they get formatted nicely e.g.:
>  https://github.com/torvalds/linux/blob/master/samples/bpf/README.rst

I was following perf's example.  Are perf's docs not RST?
