From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 18/27] bpf: Restrict kernel image access functions when the kernel is locked down
Date: Mon, 23 Oct 2017 15:53:00 +0100
Message-ID: <21530.1508770380@warthog.procyon.org.uk>
References: <20171020164343.e5mlq7ukskfjmlpp@linux-rasp2> <20171020155748.kzrvg6565oxh6gmb@linux-rasp2> <20171020024732.GJ3285@linux-l9pv.suse> <150842463163.7923.11081723749106843698.stgit@warthog.procyon.org.uk> <150842476953.7923.18174368926573855810.stgit@warthog.procyon.org.uk> <20171019221829.7m5nczg3ltqmhzom@ast-mbp> <2582.1508486928@warthog.procyon.org.uk> <19424.1508515402@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        linux-security-module@vger.kernel.org, gnomes@lxorguk.ukuu.org.uk,
        linux-efi@vger.kernel.org, matthew.garrett@nebula.com,
        gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
        jforbes@redhat.com, Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Gary Lin <GLin@suse.com>
To: jlee@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020164343.e5mlq7ukskfjmlpp@linux-rasp2>
Content-ID: <21529.1508770380.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jlee@suse.com wrote:

> hm... patch 4 only prevents write_mem() but not read_mem().
> Or I missed anything?

Actually, yes, as it happens, patch 11 prevents you from even opening /dev/mem
and /dev/kmem by locking down open of /dev/port.  So I've moved this bit to
patch 4, simplified and posted a new variant for patch 4.

David
