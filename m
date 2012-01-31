From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 24/29] sysctl: Replace root_list with links between sysctl_table_sets.
Date: Mon, 30 Jan 2012 18:11:40 -0800
Message-ID: <m1d3a0fwo3.fsf@fess.ebiederm.org>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
	<1327639925-12920-24-git-send-email-ebiederm@xmission.com>
	<20120130175112.GA20380@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>
To: Dave Jones <davej@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120130175112.GA20380@redhat.com> (Dave Jones's message of
	"Mon, 30 Jan 2012 12:51:13 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones <davej@redhat.com> writes:

> On Thu, Jan 26, 2012 at 08:52:00PM -0800, Eric W. Biederman wrote:
>
>  > +	memset(set, sizeof(*set), 0);
>
> checkpatch should warn you about this mistake.

Is there a way to tie checkpatch into git.  Perhaps into git commit?

Having something that would catch this before I embarrassed myself
certainly sounds nice.  However my overall impression of checkpatch
is that it catches newbie mistakes so unless it is trivial to run
checkpatch I don't expect I will run it because I don't expect to
tell me anything useful.

Eric
