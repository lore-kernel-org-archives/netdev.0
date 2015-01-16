From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v4 20/20] kbuild: add a new kselftest_install make
 target to install selftests
Date: Fri, 16 Jan 2015 13:59:31 +1100
Message-ID: <1421377171.18166.1.camel@ellerman.id.au>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
	 <2c5a28faaa79d9c2415854a08817ada509fcb943.1420571615.git.shuahkh@osg.samsung.com>
	 <54B69A1B.80006@osg.samsung.com> <1421362698.23332.6.camel@ellerman.id.au>
	 <54B8502C.2040708@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mmarek@suse.cz, masami.hiramatsu.pt@hitachi.com,
	gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	rostedt@goodmis.org, mingo@redhat.com, davem@davemloft.net,
	keescook@chromium.org, tranmanphong@gmail.com, cov@codeaurora.org,
	dh.herrmann@gmail.com, hughd@google.com, bobby.prani@gmail.com,
	serge.hallyn@ubuntu.com, ebiederm@xmission.com,
	tim.bird@sonymobile.com, josh@joshtriplett.org, koct9i@gmail.com,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <54B8502C.2040708@osg.samsung.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-01-15 at 16:41 -0700, Shuah Khan wrote:
> On 01/15/2015 03:58 PM, Michael Ellerman wrote:
> > On Wed, 2015-01-14 at 09:32 -0700, Shuah Khan wrote:
> >> On 01/06/2015 12:43 PM, Shuah Khan wrote:
> >>> Add a new make target to install to install kernel selftests.
> >>> This new target will build and install selftests. kselftest
> >>> target now depends on kselftest_install and runs the generated
> >>> kselftest script to reduce duplicate work and for common look
> >>> and feel when running tests.
> >>>
> >>> make kselftest_target:
> >>> -- exports kselftest INSTALL_KSFT_PATH
> >>>    default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
> >>> -- exports INSTALL_KSFT_PATH
> >>> -- runs selftests make install target
> >>>
> >>> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
> >>
> >> Hi Marek,
> >>
> >> Could you please Ack this patch, if this version looks good,
> >> so I can take this through ksefltest tree.
> > 
> > Hi Shuah,
> > 
> > I posted what I think is a better approach last week. It's less code and less
> > repetition, and installs the majority of tests this series missed - ie. the
> > powerpc ones.
> > 
> > Please at least respond to it before you put this series into next.
> > 
> > https://lkml.org/lkml/2015/1/9/45
> 
> Michael,
> 
> I didn't get a chance to review your patches yet. I plan to
> review and give you feedback by end of this week. 

Thanks. My week ends quite soon (.au time zone), so early next week is fine.

> This patch is needed in any case for either approach.

The version in my series is slightly different, but probably similar enough. I
CC'ed Michal on my series also.

cheers


