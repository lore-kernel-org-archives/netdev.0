From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/27] bpf: Restrict kernel image access functions when the kernel is locked down
Date: Fri, 20 Oct 2017 17:03:22 +0100
Message-ID: <19424.1508515402@warthog.procyon.org.uk>
References: <20171020155748.kzrvg6565oxh6gmb@linux-rasp2> <20171020024732.GJ3285@linux-l9pv.suse> <150842463163.7923.11081723749106843698.stgit@warthog.procyon.org.uk> <150842476953.7923.18174368926573855810.stgit@warthog.procyon.org.uk> <20171019221829.7m5nczg3ltqmhzom@ast-mbp> <2582.1508486928@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gnomes-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org,
        linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jforbes-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Gary Lin <GLin-IBi9RG/b67k@public.gmane.org>
To: jlee-IBi9RG/b67k@public.gmane.org
Return-path: <linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171020155748.kzrvg6565oxh6gmb@linux-rasp2>
Content-ID: <19423.1508515402.1-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

jlee-IBi9RG/b67k@public.gmane.org wrote:

> I think that we don't need to lock down sys_bpf() now because
> we didn't lock down other interfaces for reading arbitrary
> address like /dev/mem and /dev/kmem.

Ummm...  See patch 4.  You even gave me a Reviewed-by for it ;-)

David
