From: Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Subject: Re: [PATCH v4 20/20] kbuild: add a new kselftest_install make
 target to install selftests
Date: Fri, 16 Jan 2015 09:58:18 +1100
Message-ID: <1421362698.23332.6.camel@ellerman.id.au>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
	 <2c5a28faaa79d9c2415854a08817ada509fcb943.1420571615.git.shuahkh@osg.samsung.com>
	 <54B69A1B.80006@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mmarek-AlSwsSmVLrQ@public.gmane.org, masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	tim.bird-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54B69A1B.80006-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-01-14 at 09:32 -0700, Shuah Khan wrote:
> On 01/06/2015 12:43 PM, Shuah Khan wrote:
> > Add a new make target to install to install kernel selftests.
> > This new target will build and install selftests. kselftest
> > target now depends on kselftest_install and runs the generated
> > kselftest script to reduce duplicate work and for common look
> > and feel when running tests.
> > 
> > make kselftest_target:
> > -- exports kselftest INSTALL_KSFT_PATH
> >    default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
> > -- exports INSTALL_KSFT_PATH
> > -- runs selftests make install target
> > 
> > Signed-off-by: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
> 
> Hi Marek,
> 
> Could you please Ack this patch, if this version looks good,
> so I can take this through ksefltest tree.

Hi Shuah,

I posted what I think is a better approach last week. It's less code and less
repetition, and installs the majority of tests this series missed - ie. the
powerpc ones.

Please at least respond to it before you put this series into next.

https://lkml.org/lkml/2015/1/9/45

cheers
