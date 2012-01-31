From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 24/29] sysctl: Replace root_list with links between
 sysctl_table_sets.
Date: Mon, 30 Jan 2012 18:13:27 -0800
Message-ID: <1327976007.5730.8.camel@joe2Laptop>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
	 <1327639925-12920-24-git-send-email-ebiederm@xmission.com>
	 <20120130175112.GA20380@redhat.com> <m1d3a0fwo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1d3a0fwo3.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-01-30 at 18:11 -0800, Eric W. Biederman wrote:
> Is there a way to tie checkpatch into git.  Perhaps into git commit?

$ git log --format=email -p -1 $commit | \
  ./scripts/checkpatch.pl -

or maybe a front-end script prior to git commit

$ git diff --stat -p <paths> | \
  ./scripts.checkpatch.pl -
