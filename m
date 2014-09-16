From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH v2 4/4] net: sched: cls_fw: add missing
 tcf_exts_init call in fw_change()
Date: Tue, 16 Sep 2014 09:23:26 -0700
Message-ID: <CAHA+R7Oabw6XcKj+6gn2Y3eXQFQAnboKpeaatTGzUx5ZH6muBw@mail.gmail.com>
References: <20140916063024.2905.55403.stgit@nitbit.x32>
	<20140916063141.2905.59421.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:41117 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbaIPQX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:23:28 -0400
Received: by mail-la0-f49.google.com with SMTP id pv20so118984lab.36
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 09:23:27 -0700 (PDT)
In-Reply-To: <20140916063141.2905.59421.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 11:31 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> When allocating a new structure we also need to call tcf_exts_init
> to initialize exts.
>
> A follow up patch might be in order to remove some of this code
> and do tcf_exts_assign(). With this we could remove the
> tcf_exts_init/tcf_exts_change pattern for some of the classifiers.
> As part of the future tcf_actions RCU series this will need to be
> done. For now fix the call here.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Fixes: commit e35a8ee5993ba81fd6c0 ("net: sched: fw use RCU")
Acked-by: Cong Wang <cwang@twopensource.com>
