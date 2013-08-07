From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3 11/11] netfilter: use ns_printk in iptable context
Date: Wed, 7 Aug 2013 11:17:22 +0200
Message-ID: <20130807091722.GA9470@localhost>
References: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
 <1375861035-24320-12-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, akpm@linux-foundation.org,
	gaofeng@cn.fujitsu.com, guz.fnst@cn.fujitsu.com,
	libo.chen@huawei.com
To: Rui Xiang <rui.xiang@huawei.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1375861035-24320-12-git-send-email-rui.xiang@huawei.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Aug 07, 2013 at 03:37:15PM +0800, Rui Xiang wrote:
> To containerise iptables log, use ns_printk
> to report individual logs to container as
> getting syslog_ns from net->user_ns.

This patch is missing the removal of a couple of LOC at the very
beginning of ipt_log_packet and ip6t_log_packet to get this working.

Please, revamp it. Thanks.
