From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 3/3] selftests: silence test output by default
Date: Mon, 18 Sep 2017 13:52:56 -0400
Message-ID: <20170918175254.lsdzqvjm4uvix4rj@destiny>
References: <1505755982-7855-1-git-send-email-jbacik@fb.com>
 <1505756224-8187-1-git-send-email-jbacik@fb.com>
 <e8b067d2-9cef-2f3c-78a5-d6630aa765c1@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josef@toxicpanda.com, Josef Bacik <jbacik@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
        netdev@vger.kernel.org, shuah Khan <shuahkh@osg.samsung.com>
To: Shuah Khan <shuah@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e8b067d2-9cef-2f3c-78a5-d6630aa765c1@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 11:46:18AM -0600, Shuah Khan wrote:
> On 09/18/2017 11:37 AM, josef@toxicpanda.com wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > Some of the networking tests are very noisy and make it impossible to
> > see if we actually passed the tests as they run.  Default to suppressing
> > the output from any tests run in order to make it easier to track what
> > failed.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> > --
> 
> This change suppresses pass/fail wrapper output for all tests, not just the
> networking tests.
> 
> Could you please send me before and after results for what you are trying
> to fix.
> 

Yeah I wanted to suppress extraneous output from everybody, I just happened to
notice it because I was testing net.  The default thing already spits out what
it's running and pass/fail, there's no need to include all of the random output
unless the user wants to go and run the test manually.  As it is now it's
_impossible_ to tell what ran and what passed/failed because of all the random
output.

Ideally kselftests would work like xfstests does and simply capture the output
to a log so you could go check afterwards, but that's a lot more work.  Making
it easier to tell which tests passed/failed is a good enough first step.
Thanks,

Josef
