From: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [PATCH 2/6] selftests: Add install target
Date: Mon, 19 Jan 2015 09:35:54 -0700
Message-ID: <54BD326A.6030409@osg.samsung.com>
References: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au> <1420794375-31881-2-git-send-email-mpe@ellerman.id.au> <54B94E75.8030504@osg.samsung.com> <1421627752.3787.8.camel@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mmarek-AlSwsSmVLrQ@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	tim.bird-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421627752.3787.8.camel-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/18/2015 05:35 PM, Michael Ellerman wrote:
> On Fri, 2015-01-16 at 10:46 -0700, Shuah Khan wrote:
>> On 01/09/2015 02:06 AM, Michael Ellerman wrote:
>>> This adds make install support to selftests. The basic usage is:
>>>
>>> $ cd tools/testing/selftests
>>> $ make install
>>>
>>> That installs into tools/testing/selftests/install, which can then be
>>> copied where ever necessary.
>>>
>>> The install destination is also configurable using eg:
>>>
>>> $ INSTALL_PATH=/mnt/selftests make install
>>
>> Please see my response to [PATCH 4/6] kbuild: add a new
>> kselftest_install make target to install selftests
>>
>> These are addressed by the current approach to use existing
>> INSTALL_MOD_PATH.
> 
> No that's a separate issue.
> 
> This patch adds install support for tools/testing/selftests, *completely
> separate* from the kbuild infrastructure. 
> 

What's the use-case for this feature? I don't see why we need multiple
ways to do the install?

thanks,
-- Shuah


-- 
Shuah Khan
Sr. Linux Kernel Developer
Open Source Innovation Group
Samsung Research America (Silicon Valley)
shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org | (970) 217-8978
