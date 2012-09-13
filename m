From: Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH v4 2/8] cgroup: net_cls: Do not define task_cls_classid()
 when not selected
Date: Thu, 13 Sep 2012 14:35:31 +0800
Message-ID: <50517EB3.6000502@huawei.com>
References: <1347459128-32236-1-git-send-email-wagi@monom.org> <1347459128-32236-3-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <cgroups@vger.kernel.org>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:18928 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675Ab2IMGgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 02:36:39 -0400
In-Reply-To: <1347459128-32236-3-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012/9/12 22:12, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
> 
> task_cls_classid() should not be defined in case the configuration is
> CONFIG_NET_CLS_CGROUP=n. The reason is that in a following patch the
> net_cls_subsys_id will only be defined if CONFIG_NET_CLS_CGROUP!=n.
> When net_cls is not built at all a callee should only get an empty
> task_cls_classid() without any references to net_cls_subsys_id.
> 
> Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
> Acked-by: Tejun Heo <tj@kernel.org>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Li Zefan <lizefan@huawei.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: netdev@vger.kernel.org
> Cc: cgroups@vger.kernel.org

Acked-by: Li Zefan <lizefan@huawei.com>

> ---
>  include/net/cls_cgroup.h | 11 ++++++-----
>  net/core/sock.c          |  2 ++
>  2 files changed, 8 insertions(+), 5 deletions(-)
