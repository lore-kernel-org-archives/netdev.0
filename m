From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/6] selftests: Add install target
Date: Mon, 19 Jan 2015 11:35:52 +1100
Message-ID: <1421627752.3787.8.camel@ellerman.id.au>
References: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
	 <1420794375-31881-2-git-send-email-mpe@ellerman.id.au>
	 <54B94E75.8030504@osg.samsung.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:49591 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbbASAfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2015 19:35:55 -0500
In-Reply-To: <54B94E75.8030504@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 10:46 -0700, Shuah Khan wrote:
> On 01/09/2015 02:06 AM, Michael Ellerman wrote:
> > This adds make install support to selftests. The basic usage is:
> > 
> > $ cd tools/testing/selftests
> > $ make install
> > 
> > That installs into tools/testing/selftests/install, which can then be
> > copied where ever necessary.
> > 
> > The install destination is also configurable using eg:
> > 
> > $ INSTALL_PATH=/mnt/selftests make install
> 
> Please see my response to [PATCH 4/6] kbuild: add a new
> kselftest_install make target to install selftests
> 
> These are addressed by the current approach to use existing
> INSTALL_MOD_PATH.

No that's a separate issue.

This patch adds install support for tools/testing/selftests, *completely
separate* from the kbuild infrastructure. 

That is an existing use case, ie. using selftests on its own, which this patch
easily continues to support.

cheers
