From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 5/5] net_sched: clean up tcindex_set_parms()
Date: Mon, 15 Sep 2014 16:39:59 -0700
Message-ID: <CAM_iQpXSB4PvPuNV-RnsrV7Fv45rgOxy4ewk7poYYmqc-JEmoA@mail.gmail.com>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
	<1410815210-6693-6-git-send-email-xiyou.wangcong@gmail.com>
	<5417639F.10008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:62359 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756276AbaIOXj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 19:39:59 -0400
Received: by mail-ob0-f171.google.com with SMTP id uz6so1087421obc.16
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 16:39:59 -0700 (PDT)
In-Reply-To: <5417639F.10008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 3:09 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 09/15/2014 02:06 PM, Cong Wang wrote:
>> -     if (r == &new_filter_result) {
>> -             f = kzalloc(sizeof(*f), GFP_KERNEL);
>> -             if (!f)
>> -                     goto errout_alloc;
>> -     }
>> -
>
> It was put here to avoid having logic to unwind the state when/if the
> malloc fails.
>

Right, some operation after that is not undoable so we have to keep it there.
So drop this one.
