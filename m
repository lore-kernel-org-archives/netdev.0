From: Tom Herbert <tom@herbertland.com>
Subject: Re: XDP (eXpress Data Path) documentation
Date: Wed, 21 Sep 2016 17:03:24 -0700
Message-ID: <CALx6S37W2qfceOUDnPvFM5PuGp4G3cWjgrQP5_W9Veosic61pw@mail.gmail.com>
References: <20160920110844.661965be@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "iovisor-dev@lists.iovisor.org" <iovisor-dev@lists.iovisor.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Rana Shahout <rana.shahot@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@fb.com>,
        Jonathan Corbet <corbet@lwn.net>, Nathan Willis <nate@lwn.net>,
        linux-doc@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20160920110844.661965be@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2016 at 2:08 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> Hi all,
>
> As promised, I've started documenting the XDP eXpress Data Path):
>
>  [1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/index.html
>
> IMHO the documentation have reached a stage where it is useful for the
> XDP project, BUT I request collaboration on improving the documentation
> from all. (Native English speakers are encouraged to send grammar fixes ;-))
>
Hi Jesper,

Thanks for taking the initiative on the this, The document reads more
like a design doc than description right now, that's probably okay
since we could use a design doc.

Under "Important to understand" there are some disclaimers that XDP
does not implement qdiscs or BQL and fairness otherwise. This is true
for it's own traffic, but it does not (or at least should not) affect
these mechanisms or normal stack traffic running simultaneously. I
think we've made assumptions about fairness between XDP and non-XDP
queues, we probably want to clarify fairness (and also validate
whatever assumptions we've made with testing).

Thanks,
Tom

> You wouldn't believe it: But this pretty looking documentation actually
> follows the new Kernel documentation format.  It is actually just
> ".rst" text files stored in my github repository under kernel/Documentation [2]
>
>  [2] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/Documentation
>
> Thus, just git clone my repository and started editing and send me
> patches (or github pull requests). Like:
>
>  $ git clone https://github.com/netoptimizer/prototype-kernel
>  $ cd prototype-kernel/kernel/Documentation/
>  $ make html
>  $ firefox _build/html/index.html &
>
> This new documentation format combines the best of two worlds, pretty
> online browser documentation with almost plain text files, and changes
> being tracked via git commits [3] (and auto git hooks to generate the
> readthedocs.org page). You got to love it! :-)
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
>
> [3] https://github.com/netoptimizer/prototype-kernel/commits/master
