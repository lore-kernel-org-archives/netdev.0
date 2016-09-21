From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP (eXpress Data Path) documentation
Date: Wed, 21 Sep 2016 10:52:55 +0200
Message-ID: <20160921105255.5e86baae@redhat.com>
References: <20160920110844.661965be@redhat.com>
	<20160921024705.GA11128@ast-mbp.thefacebook.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nathan Willis <nate-T1hC0tSOHrs@public.gmane.org>, Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160921024705.GA11128-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2016 19:47:07 -0700
Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Tue, Sep 20, 2016 at 11:08:44AM +0200, Jesper Dangaard Brouer via iovisor-dev wrote:
> > Hi all,
> > 
> > As promised, I've started documenting the XDP eXpress Data Path):
> > 
> >  [1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/index.html
> > 
> > IMHO the documentation have reached a stage where it is useful for the
> > XDP project, BUT I request collaboration on improving the documentation
> > from all. (Native English speakers are encouraged to send grammar fixes ;-))
> > 
> > You wouldn't believe it: But this pretty looking documentation actually
> > follows the new Kernel documentation format.  It is actually just
> > ".rst" text files stored in my github repository under kernel/Documentation [2]
> > 
> >  [2] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/Documentation  
> 
> Thanks so much for doing it. This is great start!
> Some minor editing is needed here and there.
> To make it into official doc do you mind preparing a patch for Jon's doc tree ?
> If you think the doc is too volatile and not suitable for kernel.org,
> another alternative is to host it on https://github.com/iovisor
> since it's LF collaborative project it won't disappear suddenly.
> You can be a maintainer of that repo if you like.

I do see this as kernel documentation that eventually should end-up in
Jon's doc tree.  Right now it is too volatile.  Once XDP have
"stabilized" some more, I plan to push/submit the *relevant* pieces
into the kernel.  E.g. I plan to have a "proposals" section, which is
not meant upstream doc as it is an intermediate specification step
before implementing, after which it should move to another doc section.
Likewise some of the use-case documents might be "rejected" before
reaching upstream doc.

The reason I've not created a separate repository for XDP doc only, is
because I also plan to document other parts of the kernel in this
repo[3], not just XDP.  Like my page_pool work.  The documentation is
not really official documentation before it reach a kernel git tree,
together with the code it documents.

I hope this approach can help us document while developing, and
turn email discussions into specifications.  Like I forgot the
XDP_ABORTED not warning argument, which you had to re-iterate, but now
it is documented[4][5].

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[3] https://github.com/netoptimizer/prototype-kernel/
[4] https://github.com/netoptimizer/prototype-kernel/commit/a4e60e2d7a894
[5] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/implementation/userspace_api.html#troubleshooting-and-monitoring
