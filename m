From: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Subject: Re: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 6 Apr 2011 17:13:05 -0300
Message-ID: <20110406201305.GF14697@ghostprotocols.net>
References: <BANLkTikZfp_GLyNRufAzqv3Yeb5d12BPDA@mail.gmail.com>
	<20110406.121208.189703414.davem@davemloft.net>
	<20110406195719.GE14697@ghostprotocols.net>
	<20110406.130239.232756965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fedora-kernel-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jesse.brandeburg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <kernel-bounces-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110406.130239.232756965.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/kernel>,
	<mailto:kernel-request-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/kernel>
List-Post: <mailto:kernel-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>
List-Help: <mailto:kernel-request-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/kernel>,
	<mailto:kernel-request-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org?subject=subscribe>
Sender: kernel-bounces-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org
Errors-To: kernel-bounces-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org
List-Id: netdev.vger.kernel.org

Em Wed, Apr 06, 2011 at 01:02:39PM -0700, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
> Date: Wed, 6 Apr 2011 16:57:19 -0300
> 
> > Something like ftrace code changing when the user inserts the first
> > rule?
> > 
> > People wanting top performance disable it in the build, but thos wanting
> > to stick to vendor provided kernels don't have that choice :)
> 
> Using ftrace-like stubs would be an interesting idea, and I highly encourage
> people to work on something like that.

cool, these code modification and JIT mechanizms open up a lot of
possibilities indeed ;-)
 
> However I want to reiterate that I think that real rules are installed
> in Jesse's case, and once he removes those the majority of the
> overhead will disappear.  The FC14 workstation I'm using right now, on
>
> which I've made no modifications to the installer's netfilter settings,
> has the following rules:

<SNIP>
 
> I suspect Jesse has something similar on his test box.
> 
> When no rules are loaded, all the stubs make happen is a function call
> plus a list_empty() check.  Nothing more.  I really can't see that, all
> by itself, obliterating routing performance.

Yeah, would be nice, since he is playing with it, for him to post
numbers about the overheads.
 
> In fact I've done udp flood tests, as recently as a month ago, with just
> NETFILTER=y and no rules installed, and the impact was minimal.
> 
> And that was on sparc64 where function calls are expensive :)

:-)

- Arnaldo
