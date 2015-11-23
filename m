From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: Re: [PATCH 7/9] sock, cgroup: add sock->sk_cgroup
Date: Mon, 23 Nov 2015 14:02:03 +0100
Message-ID: <56530E4B.4090209@bmw-carit.de>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <1448122441-9335-8-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <lizefan@huawei.com>, <hannes@cmpxchg.org>,
	<netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<coreteam@netfilter.org>, <cgroups@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
	<ninasc@fb.com>, Neil Horman <nhorman@tuxdriver.com>
To: Tejun Heo <tj@kernel.org>, <davem@davemloft.net>,
	<pablo@netfilter.org>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>, <daniel@iogearbox.net>,
	<nhorman@tuxdriver.co>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448122441-9335-8-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 11/21/2015 05:13 PM, Tejun Heo wrote:
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>

I did a quick test and for new connection the cgroup2 match worked as
expected. For an existing connection I wasn't able to trigger the match.

It is quite likely I do something wrong:

	ssh into the box
	# mkdir /sys/fs/cgroup/test
	# echo $$ > /sys/fs/cgroup/test/cgroup.procs
	# echo $PPID > /sys/fs/cgroup/test/cgroup.procs
	# iptables -A OUTPUT -m cgroup --path test

Should I see matches with the existing ssh session?

cheers,
daniel
