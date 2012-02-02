From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Review][PATCH][0/4] sysctl bitty fixes
Date: Wed, 01 Feb 2012 19:27:51 -0800
Message-ID: <m139atx6bs.fsf@fess.ebiederm.org>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 26 Jan 2012 20:45:20 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


After digging through Lucian comments here are my incremental fixes
to address them.

This code is also available at:
kernel.org/pub/scm/linux/kernel/git/ebiederm/sysctl.git

Eric W. Biederman (4):
      sysctl: An easier to read version of find_subdir
      sysctl: Correct error return from get_subdir
      sysctl: Comments to make the code clearer.
      sysctl: Don't call sysctl_follow_link unless we are a link.

 fs/proc/proc_sysctl.c |   51 +++++++++++++++++++++++++++++++++---------------
 1 files changed, 35 insertions(+), 16 deletions(-)
