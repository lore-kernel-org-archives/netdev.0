From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH 2/6] selftests: Add install target
Date: Fri, 16 Jan 2015 10:46:29 -0700
Message-ID: <54B94E75.8030504@osg.samsung.com>
References: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au> <1420794375-31881-2-git-send-email-mpe@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	cov@codeaurora.org, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com,
	linux-kbuild@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1420794375-31881-2-git-send-email-mpe@ellerman.id.au>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/2015 02:06 AM, Michael Ellerman wrote:
> This adds make install support to selftests. The basic usage is:
> 
> $ cd tools/testing/selftests
> $ make install
> 
> That installs into tools/testing/selftests/install, which can then be
> copied where ever necessary.
> 
> The install destination is also configurable using eg:
> 
> $ INSTALL_PATH=/mnt/selftests make install

Please see my response to [PATCH 4/6] kbuild: add a new
kselftest_install make target to install selftests

These are addressed by the current approach to use existing
INSTALL_MOD_PATH.

> 
> The implementation uses two targets in the child makefiles. The first
> "install" is expected to install all files into $(INSTALL_PATH).
> 
> The second, "emit_tests", is expected to emit the test instructions (ie.
> bash script) on stdout. Separating this from install means the child
> makefiles need no knowledge of the location of the test script.

Yes. Removing the need for individual makefiles to know the install
path details would be a good improvement to make on top of my patch v4
series.

thanks,
-- Shuah


-- 
Shuah Khan
Sr. Linux Kernel Developer
Open Source Innovation Group
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
