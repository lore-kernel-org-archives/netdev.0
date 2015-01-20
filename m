From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/6] selftests: Add install target
Date: Tue, 20 Jan 2015 14:13:15 +1100
Message-ID: <1421723595.10632.2.camel@ellerman.id.au>
References: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
	 <1420794375-31881-2-git-send-email-mpe@ellerman.id.au>
	 <54B94E75.8030504@osg.samsung.com> <1421627752.3787.8.camel@ellerman.id.au>
	 <54BD326A.6030409@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mmarek@suse.cz,
	gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	rostedt@goodmis.org, mingo@redhat.com, davem@davemloft.net,
	keescook@chromium.org, tranmanphong@gmail.com, cov@codeaurora.org,
	dh.herrmann@gmail.com, hughd@google.com, bobby.prani@gmail.com,
	serge.hallyn@ubuntu.com, ebiederm@xmission.com,
	tim.bird@sonymobile.com, josh@joshtriplett.org, koct9i@gmail.com,
	linux-kbuild@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54BD326A.6030409@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-19 at 09:35 -0700, Shuah Khan wrote:
> On 01/18/2015 05:35 PM, Michael Ellerman wrote:
> > On Fri, 2015-01-16 at 10:46 -0700, Shuah Khan wrote:
> >> On 01/09/2015 02:06 AM, Michael Ellerman wrote:
> >>> This adds make install support to selftests. The basic usage is:
> >>>
> >>> $ cd tools/testing/selftests
> >>> $ make install
> >>>
> >>> That installs into tools/testing/selftests/install, which can then be
> >>> copied where ever necessary.
> >>>
> >>> The install destination is also configurable using eg:
> >>>
> >>> $ INSTALL_PATH=/mnt/selftests make install
> >>
> >> Please see my response to [PATCH 4/6] kbuild: add a new
> >> kselftest_install make target to install selftests
> >>
> >> These are addressed by the current approach to use existing
> >> INSTALL_MOD_PATH.
> > 
> > No that's a separate issue.
> > 
> > This patch adds install support for tools/testing/selftests, *completely
> > separate* from the kbuild infrastructure. 
> 
> What's the use-case for this feature? I don't see why we need multiple
> ways to do the install?

Exactly the use case I described in the sentence above.

Currently the selftests directory is usable on its own. You can copy the
selftests directory somewhere and it is functional. That is a useful feature,
and there's no reason to break it.

cheers
