From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH v2 3/4] net: sched: cls_cgroup fix possible
 memory leak of 'new'
Date: Tue, 16 Sep 2014 09:19:52 -0700
Message-ID: <CAHA+R7Mjb6Fe4SFRAuox7ep56T7YsmnbZmPAC3H0P_iB0hFNNg@mail.gmail.com>
References: <20140916063024.2905.55403.stgit@nitbit.x32>
	<20140916063115.2905.53827.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:49939 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050AbaIPQTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:19:54 -0400
Received: by mail-lb0-f180.google.com with SMTP id b12so120713lbj.11
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 09:19:52 -0700 (PDT)
In-Reply-To: <20140916063115.2905.53827.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 11:31 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   54996b529ab70ca1d6f40677cd2698c4f7127e87
> commit: c7953ef23042b7c4fc2be5ecdd216aacff6df5eb [625/646] net: sched: cls_cgroup use RCU
>
> net/sched/cls_cgroup.c:130 cls_cgroup_change() warn: possible memory leak of 'new'
> net/sched/cls_cgroup.c:135 cls_cgroup_change() warn: possible memory leak of 'new'
> net/sched/cls_cgroup.c:139 cls_cgroup_change() warn: possible memory leak of 'new'
>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Fixes: commit: c7953ef23042b7c4fc2be5ecdd216aac ("net: sched:
cls_cgroup use RCU")
Acked-by: Cong Wang <cwang@twopensource.com>
