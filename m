From: joeyli <jlee-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH 20/24] bpf: Restrict kernel image access functions when
 the kernel is locked down
Date: Wed, 12 Apr 2017 22:57:36 +0800
Message-ID: <20170412145736.GF18270@linux-l9pv.suse>
References: <149142326734.5101.4596394505987813763.stgit@warthog.procyon.org.uk>
 <149142344547.5101.4518618716303032193.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        gnomes-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <149142344547.5101.4518618716303032193.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

First, thanks for your help to send out this series.

On Wed, Apr 05, 2017 at 09:17:25PM +0100, David Howells wrote:
> From: Chun-Yi Lee <jlee-IBi9RG/b67k@public.gmane.org>
> 
> There are some bpf functions can be used to read kernel memory:
> bpf_probe_read, bpf_probe_write_user and bpf_trace_printk.  These allow
> private keys in kernel memory (e.g. the hibernation image signing key) to
> be read by an eBPF program.  Prohibit those functions when the kernel is
> locked down.
> 
> Signed-off-by: Chun-Yi Lee <jlee-IBi9RG/b67k@public.gmane.org>
> Signed-off-by: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

This patch is used with hibernation signature verification. I suggest
that we can remove this patch from your series because we just lock
down the hibernation function until hibernation verification get
accepted.

On the other hand, we are trying to enhance the bpf verifier to
prevent bpf print reads specific memory addresses that have sensitive
data.

Thanks a lot!
Joey Lee
