From: jlee@suse.com
Subject: Re: [PATCH 18/27] bpf: Restrict kernel image access functions when
 the kernel is locked down
Date: Fri, 20 Oct 2017 23:57:48 +0800
Message-ID: <20171020155748.kzrvg6565oxh6gmb@linux-rasp2>
References: <20171020024732.GJ3285@linux-l9pv.suse>
 <150842463163.7923.11081723749106843698.stgit@warthog.procyon.org.uk>
 <150842476953.7923.18174368926573855810.stgit@warthog.procyon.org.uk>
 <20171019221829.7m5nczg3ltqmhzom@ast-mbp>
 <2582.1508486928@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        linux-security-module@vger.kernel.org, gnomes@lxorguk.ukuu.org.uk,
        linux-efi@vger.kernel.org, matthew.garrett@nebula.com,
        gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
        jforbes@redhat.com, Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Gary Lin <GLin@suse.com>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2582.1508486928@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, 2017 at 09:08:48AM +0100, David Howells wrote:
> Hi Joey,
> 
> Should I just lock down sys_bpf() entirely for now?  We can always free it up
> somewhat later.
> 
> David

OK~~ Please just remove my patch until we find out a way to
verify bpf code or protect sensitive data in memory.

I think that we don't need to lock down sys_bpf() now because
we didn't lock down other interfaces for reading arbitrary
address like /dev/mem and /dev/kmem.

Thanks a lot!
Joey Lee
