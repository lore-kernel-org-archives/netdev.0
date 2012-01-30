From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 24/29] sysctl: Replace root_list with links between
 sysctl_table_sets.
Date: Mon, 30 Jan 2012 12:51:13 -0500
Message-ID: <20120130175112.GA20380@redhat.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
 <1327639925-12920-24-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1327639925-12920-24-git-send-email-ebiederm@xmission.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 26, 2012 at 08:52:00PM -0800, Eric W. Biederman wrote:

 > +	memset(set, sizeof(*set), 0);

checkpatch should warn you about this mistake.

	Dave
