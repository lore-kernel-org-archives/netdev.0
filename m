From: joeyli <jlee-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH 18/27] bpf: Restrict kernel image access functions when
 the kernel is locked down
Date: Wed, 25 Oct 2017 15:07:30 +0800
Message-ID: <20171025070730.GH8550@linux-l9pv.suse>
References: <20171020164343.e5mlq7ukskfjmlpp@linux-rasp2>
 <20171020155748.kzrvg6565oxh6gmb@linux-rasp2>
 <20171020024732.GJ3285@linux-l9pv.suse>
 <150842463163.7923.11081723749106843698.stgit@warthog.procyon.org.uk>
 <150842476953.7923.18174368926573855810.stgit@warthog.procyon.org.uk>
 <20171019221829.7m5nczg3ltqmhzom@ast-mbp>
 <2582.1508486928@warthog.procyon.org.uk>
 <19424.1508515402@warthog.procyon.org.uk>
 <21530.1508770380@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gnomes-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org,
        linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jforbes-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Gary Lin <GLin-IBi9RG/b67k@public.gmane.org>
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <21530.1508770380-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 23, 2017 at 03:53:00PM +0100, David Howells wrote:
> jlee-IBi9RG/b67k@public.gmane.org wrote:
> 
> > hm... patch 4 only prevents write_mem() but not read_mem().
> > Or I missed anything?
> 
> Actually, yes, as it happens, patch 11 prevents you from even opening /dev/mem
> and /dev/kmem by locking down open of /dev/port.  So I've moved this bit to
> patch 4, simplified and posted a new variant for patch 4.
>

Thank you for pointing out!

Joey Lee
