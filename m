From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 8/8] netfilter: implement xt_cgroup cgroup2 path match
Date: Mon, 14 Dec 2015 20:37:55 +0100
Message-ID: <20151214193755.GB18238@salvia>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
 <1449527935-27056-9-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, kadlec@blackhole.kfki.hu,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com, ninasc@fb.com,
	Jan Engelhardt <jengelh@inai.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449527935-27056-9-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2015 at 05:38:55PM -0500, Tejun Heo wrote:
> This patch implements xt_cgroup path match which matches cgroup2
> membership of the associated socket.  The match is recursive and
> invertible.

Applied, thanks.

I shared the same concerns as Florian regarding the large size of the
path field in iptables, but given that we expose the layout of our
internal representation there (which is bad in terms of
extensibility), the only solution that I can see is to artificially
limitate the size of that field, but that may break users depending on
the scenario.

Hopefully, we should be able to provide something better in nf_tables
to address this.
