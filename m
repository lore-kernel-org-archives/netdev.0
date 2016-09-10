From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 0/9] Move runnable code (tests) from Documentation to
 selftests
Date: Sat, 10 Sep 2016 01:01:00 -0600
Message-ID: <20160910010100.72f1a9c4@lwn.net>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: richardcochran@gmail.com, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  9 Sep 2016 16:22:41 -0600
Shuah Khan <shuahkh@osg.samsung.com> wrote:

> Move runnable code (tests) from Documentation to selftests and update
> Makefiles to work under selftests.
> 
> Jon Corbet and I discussed this in an email thread and as per that
> discussion, this patch series moves all the tests that are under the
> Documentation directory to selftests. There is more runnable code in
> the form of examples and utils and that is going to be another patch
> series. I moved just the tests and left the documentation files as is.

I'm fine with the idea, but it looks like a couple of tweaks are needed,
in particular to avoid leaving behind dangling references in
Documentation/Makefile that cause build errors.

I think the individual patches probably need a wider CC list as well.
I'd use the get_maintainer script (or git) to see who has taken an
interest in the individual tests and make sure they are aware of the
move.

Thanks,

jon
