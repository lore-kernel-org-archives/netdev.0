From: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [PATCH v2 07/19] selftests/firmware: add install target to enable
 installing test
Date: Wed, 19 Nov 2014 09:13:43 -0700
Message-ID: <546CC1B7.70600@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com> <1d2d13556ddbbbbb13989cdcb08447909bc4afaf.1415735831.git.shuahkh@osg.samsung.com> <CAGXu5j+yLqH0xj=5N90LRmK9F1xPLVWBy+cyUCzjvKJH7gE7AA@mail.gmail.com> <5462B2A3.9000007@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Phong Tran <tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	pranith kumar <bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	linux-kbuild <linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5462B2A3.9000007-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/11/2014 06:06 PM, Shuah Khan wrote:
> On 11/11/2014 02:29 PM, Kees Cook wrote:
>> Hi,
>>
>> Sorry, I still really don't like this approach. While it is all in one
>> place (thank you for that), I think it isn't a form that is very
>> workable for the people maintaining the self tests. How about this,
>> instead of per-Makefile customization, why not define an execution
>> framework for these tests instead.
> 
> If I understand correctly, sounds like you don't like the way
> install target is implemented in the individual test Makefiles
> and the changes I made to run_tests targets to address the code
> duplication concern.
> 
> At the moment there is no duplicate code in this patch series
> between install and run_tests targets. This is a  first step
> towards standardizing the framework and a definite improvement
> over what we have currently. As I mentioned earlier, my goal
> is to make it easier for developers to install and run the
> existing tests and evolve the framework as we go.
> 
> Assuming my understanding is correct that:
> 
> -- install and run_tests targets in individual tests can be
>    refined and automated with a common Makefile approach you
>    proposed.
> -- the rest of the user-interface kselftest_install and kselftest
>    are good.
> 
> I would like to propose that we get started with the current
> implementation and refine it based on the following ideas you
> suggested. The refinements you are recommending are confined
> to selftests and can be made after the kselftest_install
> gets added. Adding kselftest_install makes it easier to make
> the refinements as it defines overall UI.
> 

Hi Kees,

Are you ok with the above proposal? I understand this approach
might not be perfect, however it is a step in the right direction
to enable and make it easier to run them. I would like to get some
initial work in for 3.19 if at all possible.

I plan to evolve the back-end to make it easier to write and
maintain for developers writing tests going forward.

thanks,
-- Shuah


-- 
Shuah Khan
Sr. Linux Kernel Developer
Samsung Research America (Silicon Valley)
shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org | (970) 217-8978
